
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
import ConfigReg::*;
import SyncTestIF::*;
import SyncTestCommon::*;

interface SyncTestSingle;
    // request
    method Action start(Bit#(64) num, TestMode mode);
    // indication inverse
    method ActionValue#(Bit#(64)) done;
    method ActionValue#(Bit#(64)) err;
endinterface

typedef enum {Init, Test, Done} State deriving(Bits, Eq);

module mkSyncTestSingle#(
    Clock fastClk,
    Reset fastRst,
    Bit#(8) fastDelayCycles, // under fastClk
    Integer fifoSz
)(
    SyncTestSingle
);
    Clock curClk <- exposeCurrentClock;
    Reset curRst <- exposeCurrentReset;

    // pair of sync FIFOs
    SyncFIFOIfc#(TestData) sendQ; // current clk to fast clk
    SyncFIFOIfc#(TestData) recvQ; // fast clk to current clk

    if(fifoSz <= 16) begin
        sendQ <- mkSyncFifo(fifoSz, curClk, curRst, fastClk, fastRst);
        recvQ <- mkSyncFifo(fifoSz, fastClk, fastRst, curClk, curRst);
    end
    else begin
        sendQ <- mkSyncBramFifo(fifoSz, curClk, curRst, fastClk, fastRst);
        recvQ <- mkSyncBramFifo(fifoSz, fastClk, fastRst, curClk, curRst);
    end

    // fast clock delay
    Reg#(Bit#(8)) delayCnt <- mkReg(0, clocked_by fastClk, reset_by fastRst);

    // test bookkeepings
    Reg#(State) state <- mkReg(Init);
    Reg#(TestMode) mode <- mkRegU;
    Reg#(Bit#(64)) testNum <- mkRegU;
    Reg#(Bit#(64)) sendNum <- mkReg(0);
    Reg#(Bit#(64)) recvNum <- mkReg(0);
    Reg#(Bit#(64)) clk <- mkConfigReg(0);
    Reg#(Bit#(64)) elapTime <- mkReg(0);

    // indication Q
    FIFO#(Bit#(64)) doneQ <- mkFIFO;
    FIFO#(Bit#(64)) errQ <- mkFIFO;

    (* fire_when_enabled, no_implicit_conditions *)
    rule incrCLK(state == Test);
        clk <= clk + 1;
    endrule

    rule do_throughput_send(state == Test && mode == Throughput && sendNum < testNum);
        sendQ.enq(getTestData(sendNum));
        sendNum <= sendNum + 1;
    endrule

    rule do_throughput_recv(state == Test && mode == Throughput && recvNum < testNum);
        recvQ.deq;
        let recv = recvQ.first;
        // check correctness
        if(getTestData(recvNum) == recv) begin
        end
        else begin
            errQ.enq(recvNum);
        end
        // incr num
        recvNum <= recvNum + 1;
        // record time
        if(recvNum == 0) begin
            elapTime <= clk;
        end
        else if(recvNum == testNum - 1) begin
            elapTime <= clk - elapTime;
        end
    endrule

    rule do_latency_send(state == Test && mode == Latency && sendNum == 0);
        sendQ.enq(getTestData(sendNum));
        sendNum <= 1;
    endrule

    rule do_latency_recv(state == Test && mode == Latency && recvNum < testNum && sendNum > 0);
        recvQ.deq;
        let recv = recvQ.first;
        // check correctness
        if(getTestData(recvNum) == recv) begin
        end
        else begin
            errQ.enq(recvNum);
        end
        // incr num
        recvNum <= recvNum + 1;
        // send another
        if(recvNum < testNum - 1) begin
            sendQ.enq(getTestData(sendNum));
            sendNum <= sendNum + 1;
        end
        // record time
        if(recvNum == 0) begin
            elapTime <= clk;
        end
        else if(recvNum == testNum - 1) begin
            elapTime <= clk - elapTime;
        end
    endrule

    rule do_test_done(state == Test && recvNum == testNum);
        doneQ.enq(elapTime);
        state <= Done; // become idling
    endrule

    // delay in fast clock domain
    rule doFast_delay(delayCnt < fastDelayCycles && sendQ.notEmpty);
        delayCnt <= delayCnt + 1;
    endrule

    rule doFast_action(delayCnt == fastDelayCycles);
        delayCnt <= 0;
        sendQ.deq;
        recvQ.enq(sendQ.first);
    endrule

    method Action start(Bit#(64) num, TestMode m) if(state == Init);
        testNum <= num;
        mode <= m;
        state <= Test;
    endmethod

    method ActionValue#(Bit#(64)) done;
        doneQ.deq;
        return doneQ.first;
    endmethod

    method ActionValue#(Bit#(64)) err;
        errQ.deq;
        return errQ.first;
    endmethod
endmodule
