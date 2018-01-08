
// Copyright (c) 2017 Massachusetts Institute of Technology
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import FIFO::*;
import Clocks::*;
import BRAMFIFO::*;
import ConfigReg::*;
import GetPut::*;

import DramCommon::*;
import DRTestIF::*;
import Brams::*;
import Random::*;
import SyncFifo::*;

typedef struct {
    Bool pass;
    Bit#(64) elapTime;
    Bit#(64) rdLatSum;
    Bit#(64) rdNum;
} DoneResp deriving(Bits, Eq);

interface DRTest;
    // request
    method Action setup(Bit#(64) data, SetupType t);
    // indication inverse
    method ActionValue#(TestAddrIdx) inited; // return addr num (max addr idx + 1)
    method ActionValue#(DoneResp) done;
    method ActionValue#(Bit#(64)) err;
    // DRAM
    method ActionValue#(DramUserReq) dramReq;
    method Action dramResp(DramUserData d);
endinterface

typedef enum {
    Setup, // recv DRAM addr to test from host and init data
    InitData, // initialize each DRAM addr to test
    Test, // send test req and check resp for reads
    Check, // check all data after all test req
    WaitDone, // wait all reads to resp & send perf counters to host
    Finish // idling...
} TestState deriving(Bits, Eq);

(* synthesize *)
module mkDRTest#(Clock portalClk, Reset portalRst)(DRTest);
    // test params
    Reg#(TestState) state <- mkReg(Setup);
    Reg#(Bit#(64)) testNum <- mkReg(0);

    // addr reg to init/check data
    Reg#(TestAddrIdx) addrIdx <- mkReg(0);
    // max idx of tested addr, should be 0..0111..111
    Reg#(TestAddrIdx) addrIdxMask <- mkReg(0);

    // test counters
    Reg#(Bit#(64)) clk <- mkConfigReg(0);
    Reg#(Bit#(64)) beginTime <- mkReg(0);
    Reg#(Bit#(64)) rdLatSum <- mkReg(0);
    Reg#(Bit#(64)) sendCnt <- mkReg(0);
    Reg#(Bit#(64)) sendRdCnt <- mkReg(0);
    Reg#(Bit#(64)) recvRdCnt <- mkReg(0);
    Reg#(Bool) hasError <- mkReg(False);

    // test randomizer
    let randData <- mkRandDramUserData;
    let randBE <- mkRandDramUserBE;
    let randAddrIdx <- mkRandAddrIdx;
    let randSendStall <- mkRandStall;
    let randRecvStall <- mkRandStall;
    
    // test addr & ref data
    AddrBram addrRam <- mkAddrBram;
    DataBram dataRam <- mkDataBram;

    // generate Dram req is split into 3 stages
    // 1. control part: select addr idx to send req
    // 2. issue part: get idx and send Dram req, and change ram
    // 3. answer part: store result (of read req) into refQ
    // FIFO to hold test addr idx & cmd (stage 1 -> 2)
    FIFO#(Tuple2#(TestAddrIdx, DramUserBE)) testReqQ <- mkFIFO;
    // reference DRAM read resp and read req issue time
    FIFO#(Tuple2#(DramUserData, Bit#(64))) refQ <- mkSizedBRAMFIFO(1024);
    
    // sync FIFOs for req & indication
    Clock userClk <- exposeCurrentClock;
    Reset userRst <- exposeCurrentReset;
    // req Q
    SyncFIFOIfc#(Tuple2#(Bit#(64), SetupType)) setupQ <- mkSyncFifo(1, portalClk, portalRst, userClk, userRst);
    // indication Q
    SyncFIFOIfc#(TestAddrIdx) initQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);
    SyncFIFOIfc#(DoneResp) doneQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);
    SyncFIFOIfc#(Bit#(64)) errQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);

    // DRAM fifos
    FIFO#(DramUserReq) dramReqQ <- mkFIFO;
    FIFO#(DramUserData) dramRespQ <- mkFIFO;

    (* fire_when_enabled, no_implicit_conditions *)
    rule incCLK;
        clk <= clk + 1;
    endrule

    // do setup
    (* fire_when_enabled *)
    rule doSetup(state == Setup);
        setupQ.deq;
        match {.data, .t} = setupQ.first;
        if(t == TestNum) begin
            testNum <= data;
        end
        else if(t == DataSeed) begin
            randData.seed(truncate(data));
        end
        else if(t == BESeed) begin
            randBE.seed(truncate(data));
        end
        else if(t == IdxSeed) begin
            randAddrIdx.seed(truncate(data));
        end
        else if(t == SendStall) begin
            randSendStall.setRatio(truncate(data));
        end
        else if(t == RecvStall) begin
            randRecvStall.setRatio(truncate(data));
        end
        else if(t == Addr) begin
            addrRam.req(True, addrIdx, truncate(data)); // record addr
            addrIdx <= addrIdx + 1; // go to next idx
        end
        else if(t == Start) begin
            addrIdxMask <= addrIdx - 1; // record max idx, should be 'b00..0011..11
            addrIdx <= 0; // reset for later reuse
            state <= InitData; // start init data
            // in check state we will send read for each addr
            // add this amount to sendRdCnt at one shot
            // so that only when we recv all read resp, we get sendRdCnt == recvRdCnt
            // notice that addrIdx may be all 0
            sendRdCnt <= addrIdx == 0 ? fromInteger(valueOf(TExp#(LogMaxAddrNum))) : zeroExtend(addrIdx);
            $display("%t DRTest %m: setup done, addrIdx = %x", $time, addrIdx);
        end
        else begin
            $fdisplay(stderr, "ERROR: %t DRTest %m: unknown setup type %d", $time, t);
            $finish;
        end
    endrule

    // recv DRAM resp and check
    (* fire_when_enabled *)
    rule doRecv(!randRecvStall.value);
        refQ.deq;
        match {.ans, .issueTime} = refQ.first;
        dramRespQ.deq;
        let resp = dramRespQ.first;
        if(ans == resp) begin
        end
        else begin
            errQ.enq(recvRdCnt);
            hasError <= True;
        end
        // update stats
        recvRdCnt <= recvRdCnt + 1;
        rdLatSum <= rdLatSum + (clk - issueTime);
    endrule

    // stop test & send perf counters
    (* fire_when_enabled *)
    rule doDone(state == WaitDone && recvRdCnt == sendRdCnt);
        doneQ.enq(DoneResp {
            pass: !hasError,
            elapTime: clk - beginTime,
            rdLatSum: rdLatSum,
            rdNum: recvRdCnt
        });
        state <= Finish;
        $display("%t DRTest %m: done msg sent", $time);
    endrule

    // stage 1: control: select addr idx: different behavior in different test state
    // init data
    (* fire_when_enabled *)
    rule doSelAddr_InitData(state == InitData);
        // get addr
        addrRam.req(False, addrIdx, ?);
        // pass req info to stage 2 (write all bytes)
        testReqQ.enq(tuple2(addrIdx, maxBound));
        // change state
        if(addrIdx == addrIdxMask) begin
            addrIdx <= 0; // reset for later reuse
            initQ.enq(addrIdxMask); // tell host i am inited
            state <= Test; // start testing
            $display("%t DRTest %m: data inited, idx mask = %x", $time, addrIdxMask);
        end
        else begin
            addrIdx <= addrIdx + 1;
        end
        // record begin time
        if(addrIdx == 0) begin
            beginTime <= clk;
        end
    endrule

    // test
    (* fire_when_enabled *)
    rule doSelAddr_Test(state == Test && !randSendStall.value); // check stall signal
        // get random addr idx (need masking...)
        TestAddrIdx idx <- randAddrIdx.getVal;
        idx = idx & addrIdxMask;
        addrRam.req(False, idx, ?);
        // pass req to stage 2 (random read or write)
        DramUserBE be <- randBE.getVal;
        testReqQ.enq(tuple2(idx, be));
        // change state
        sendCnt <= sendCnt + 1;
        if(be == 0) begin
            sendRdCnt <= sendRdCnt + 1;
        end
        if(sendCnt == testNum - 1) begin
            state <= Check;
            $display("%t DRTest %m: test req all sent", $time);
        end
        if(((sendCnt + 1) & 64'h03FF) == 0) begin
            $display("%t DRTest %m: %d requests already sent", $time, sendCnt + 1);
        end
    endrule

    // check
    (* fire_when_enabled *)
    rule doSelAddr_Check(state == Check);
        // get addr
        addrRam.req(False, addrIdx, ?);
        // pass req info to stage 2 (read)
        testReqQ.enq(tuple2(addrIdx, 0));
        // change state
        if(addrIdx == addrIdxMask) begin
            addrIdx <= 0;
            state <= WaitDone;
            $display("%t DRTest %m: check req all sent", $time);
        end
        else begin
            addrIdx <= addrIdx + 1;
        end
        // no need to incr sendRdCnt now (already done in Setup state)
    endrule

    // stage 2: real req
    (* fire_when_enabled *)
    rule doReqDram; 
        // get idx & addr
        testReqQ.deq;
        match {.idx, .be} = testReqQ.first;
        DramUserAddr addr <- addrRam.resp;
        // random data
        DramUserData data <- randData.getVal;
        // assemble req
        let req = DramUserReq {
            addr: addr,
            data: data,
            wrBE: be
        };
        // apply change to dataRam
        dataRam.req(idx, req.wrBE, req.data);
        // send to DRAM
        dramReqQ.enq(req);
    endrule

    // stage 3: save answer
    (* fire_when_enabled *)
    rule doStoreAns;
        let r <- dataRam.resp;
        // since refQ is very large, it may never block
        // so req issue time is clk - 1
        refQ.enq(tuple2(r, clk - 1));
    endrule

    method Action setup(Bit#(64) data, SetupType t);
        setupQ.enq(tuple2(data, t));
    endmethod

    method inited = toGet(initQ).get;
    method done = toGet(doneQ).get;
    method err = toGet(errQ).get;

    method dramReq = toGet(dramReqQ).get;
    method dramResp = toPut(dramRespQ).put;
endmodule
