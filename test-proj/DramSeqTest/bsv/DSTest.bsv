
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

import ConfigReg::*;
import FIFOF::*;
import FIFO::*;
import BRAMFIFO::*;
import DramCommon::*;
import Vector::*;
import Clocks::*;
import SyncFifo::*;

typedef struct {
    Bit#(32) testId;
    // for throughput
    Bit#(64) wrTime;
    Bit#(64) rdTime;
    // for latency
    Bit#(64) rdLatSum;
} DoneResp deriving(Bits, Eq);

typedef struct {
    Bit#(32) testId;
    Bit#(32) rdAddr;
} ErrResp deriving(Bits, Eq);

interface DSTest;
    // request
    method Action start(Bit#(32) num);
    // indication inverse
    method ActionValue#(DoneResp) done;
    method ActionValue#(ErrResp) err;
    // interface to Dram
    method ActionValue#(DramUserReq) dramReq;
    method Action dramResp(DramUserData d);
endinterface

typedef enum {Init, Write, Read, Done, Finish} TestState deriving(Bits, Eq);

typedef Bit#(24) DramTestAddr; // test 1GB space (in 64B blocks)

(* synthesize *)
module mkDSTest#(Clock portalClk, Reset portalRst)(DSTest);
    Reg#(Bit#(32)) testNum <- mkReg(0);
    Reg#(Bit#(32)) testId <- mkReg(0);
    Reg#(DramTestAddr) reqAddr <- mkReg(0);
    Reg#(DramTestAddr) respAddr <- mkReg(0); // for read only
    Reg#(Bool) readReqDone <- mkReg(False); // read req all sent
    Reg#(TestState) state <- mkReg(Init);

    // clocks & perf
    Reg#(Bit#(64)) clk <- mkConfigReg(0);
    // phase start time (for throughput)
    Reg#(Bit#(64)) wrTime <- mkReg(0);
    Reg#(Bit#(64)) rdTime <- mkReg(0);
    // latency sum
    Reg#(Bit#(64)) rdLatSum <- mkReg(0);
    // rd req issue time Q (for latency)
    FIFOF#(Bit#(64)) rdIssueTimeQ <- mkSizedBRAMFIFOF(1024);

    Clock userClk <- exposeCurrentClock;
    Reset userRst <- exposeCurrentReset;
    // request FIFOs
    SyncFIFOIfc#(Bit#(32)) startQ <- mkSyncFifo(1, portalClk, portalRst, userClk, userRst);
    // indicatoin FIFOs
    SyncFIFOIfc#(DoneResp) doneQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);
    SyncFIFOIfc#(ErrResp) errQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);
    // dram FIFOs
    FIFO#(DramUserReq) dramReqQ <- mkFIFO;
    FIFO#(DramUserData) dramRespQ <- mkFIFO;


    (* fire_when_enabled, no_implicit_conditions *)
    rule incCLK(state != Init);
        clk <= clk + 1;
    endrule

    rule doStart(state == Init);
        startQ.deq;
        testNum <= startQ.first;
        state <= Write;
    endrule

    rule doWrite(state == Write);
        Vector#(16, Bit#(32)) data = replicate(testId + zeroExtend(reqAddr));
        dramReqQ.enq(DramUserReq {
            addr: zeroExtend(reqAddr),
            data: pack(data),
            wrBE: maxBound
        });
        reqAddr <= reqAddr + 1; // wrap back to 0 when all writes are done
        // record time & change state
        if(reqAddr == 0) begin
            wrTime <= clk; // record start time
        end
        else if(reqAddr == maxBound) begin
            wrTime <= clk - wrTime; // get total time
            state <= Read; // do read next
        end
    endrule

    rule doReadReq(state == Read && !readReqDone);
        dramReqQ.enq(DramUserReq {
            addr: zeroExtend(reqAddr),
            data: ?,
            wrBE: 0
        });
        reqAddr <= reqAddr + 1; // wrap back to 0 when all reads are sent
        // record time & change state
        rdIssueTimeQ.enq(clk); // issue time (for latency)
        if(reqAddr == maxBound) begin
            readReqDone <= True; // stop sending req, wait for remaining resp
        end
    endrule

    rule doReadResp(state == Read);
        dramRespQ.deq;
        DramUserData resp = dramRespQ.first;
        respAddr <= respAddr + 1; // wrap back to 0 when all reads are received 
        // check resp correctness
        Vector#(16, Bit#(32)) answer = replicate(testId + zeroExtend(respAddr));
        if(pack(answer) == resp) begin
        end
        else begin
            errQ.enq(ErrResp {
                testId: testId,
                rdAddr: zeroExtend(respAddr)
            });
            $fdisplay(stderr, "ERROR: %t DSTest %m: test %d read %x get wrong %x != %x",
                $time, testId, respAddr, resp, pack(answer)
            );
        end
        // get latency
        rdIssueTimeQ.deq;
        Bit#(64) issueTime = rdIssueTimeQ.first;
        rdLatSum <= rdLatSum + (clk - issueTime);
        // get throughput & change state
        if(respAddr == 0) begin
            rdTime <= clk; // start time
        end
        else if(respAddr == maxBound) begin
            rdTime <= clk - rdTime; // total time
            state <= Done; // go to send done signal
        end
    endrule

    rule doDone(state == Done);
        doneQ.enq(DoneResp {
            testId: testId,
            wrTime: wrTime,
            rdTime: rdTime,
            rdLatSum: rdLatSum
        }); 
        // incr test id & clear everything
        testId <= testId + 1;
        readReqDone <= False;
        wrTime <= 0;
        rdTime <= 0;
        rdLatSum <= 0;
        state <= ((testId + 1) < testNum) ? Write : Finish;
    endrule

    method Action start(Bit#(32) num);
        startQ.enq(num);
    endmethod

    method ActionValue#(DoneResp) done;
        doneQ.deq;
        return doneQ.first;
    endmethod

    method ActionValue#(ErrResp) err;
        errQ.deq;
        return errQ.first;
    endmethod

    method ActionValue#(DramUserReq) dramReq;
        dramReqQ.deq;
        return dramReqQ.first;
    endmethod

    method Action dramResp(DramUserData d);
        dramRespQ.enq(d);
    endmethod
endmodule
