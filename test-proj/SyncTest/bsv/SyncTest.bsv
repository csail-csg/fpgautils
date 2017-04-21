
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
import SyncFifo::*;
import Vector::*;
import SyncTestIF::*;
import SyncTestCommon::*;
import SyncTestSingle::*;

typedef struct {
    Bit#(8) logFifoSz;
    Bit#(64) totalTime;
} DoneResp deriving(Bits, Eq);

typedef struct {
    Bit#(8) logFifoSz;
    Bit#(64) recvNum;
} ErrResp deriving(Bits, Eq);

interface SyncTest;
    // request
    method Action start(Bit#(64) num, TestMode mode, Bit#(8) delay);
    // indication inverse
    method ActionValue#(DoneResp) done;
    method ActionValue#(ErrResp) err;
endinterface

typedef struct {
    Bit#(64) testNum;
    TestMode mode;
    Bit#(8) fastDelay;
} StartReq deriving(Bits, Eq);

(* synthesize *)
module mkSyncTest#(Clock portalClk, Reset portalRst, Clock fastClk, Reset fastRst)(SyncTest);
    Clock curClk <- exposeCurrentClock;
    Reset curRst <- exposeCurrentReset;

    // reqeusts
    SyncFIFOIfc#(StartReq) startQ <- mkSyncFifo(1, portalClk, portalRst, curClk, curRst);
    // indications
    SyncFIFOIfc#(DoneResp) doneQ <- mkSyncFifo(1, curClk, curRst, portalClk, portalRst);
    SyncFIFOIfc#(ErrResp) errQ <- mkSyncFifo(1, curClk, curRst, portalClk, portalRst);

    // delay cycles in fast clock domain
    Reg#(Bit#(8)) fastDelayCycles <- mkReg(0, clocked_by fastClk, reset_by fastRst); // prevent some reset issue?
    // transfer the delay param to fast clock domain
    SyncFIFOIfc#(Bit#(8)) setDelayQ <- mkSyncFifo(1, curClk, curRst, fastClk, fastRst);
    // after seting the delay, we get start
    SyncFIFOIfc#(Bool) initQ <- mkSyncFifo(1, fastClk, fastRst, curClk, curRst);

    // test setting params (at main clock domain)
    Reg#(Bit#(64)) testNum <- mkReg(0); // 0 is invalid test num
    Reg#(TestMode) mode <- mkRegU;

    // test modules
    Vector#(TAdd#(LogMaxFifoSz, 1), SyncTestSingle) tests = ?;
    for(Integer i = 0; i <= valueOf(LogMaxFifoSz); i = i+1) begin
        tests[i] <- mkSyncTestSingle(fastClk, fastRst, fastDelayCycles, 2 ** i);
    end

    // start up initialization
    rule getStartReq;
        startQ.deq;
        StartReq r = startQ.first;
        testNum <= r.testNum; // this should > 0 to truly start test
        mode <= r.mode;
        setDelayQ.enq(r.fastDelay);
        $display("%t SyncTest %m: get start req %d %d %d", $time, r.testNum, r.mode, r.fastDelay);
    endrule

    rule doSetDelay;
        setDelayQ.deq;
        fastDelayCycles <= setDelayQ.first;
        initQ.enq(?);
        $display("%t SyncTest %m: set delay %d", $time, setDelayQ.first);
    endrule

    rule doStartTests(testNum > 0); // start test when testNum is set & delay is set
        initQ.deq;
        for(Integer i = 0; i <= valueOf(LogMaxFifoSz); i = i+1) begin
            tests[i].start(testNum, mode);
        end
        $display("%t SyncTest %m: init %d %d", $time, testNum, mode);
    endrule

    // indications
    for(Integer i = 0; i <= valueOf(LogMaxFifoSz); i = i+1) begin
        rule doDone;
            let t <- tests[i].done;
            doneQ.enq(DoneResp {
                logFifoSz: fromInteger(i),
                totalTime: t
            });
        endrule

        rule doErr;
            let n <- tests[i].err;
            errQ.enq(ErrResp {
                logFifoSz: fromInteger(i),
                recvNum: n
            });
        endrule
    end

    method Action start(Bit#(64) num, TestMode m, Bit#(8) delay);
        startQ.enq(StartReq {
            testNum: num,
            mode: m,
            fastDelay: delay
        });
    endmethod

    method ActionValue#(DoneResp) done;
        doneQ.deq;
        return doneQ.first;
    endmethod

    method ActionValue#(ErrResp) err;
        errQ.deq;
        return errQ.first;
    endmethod
endmodule
