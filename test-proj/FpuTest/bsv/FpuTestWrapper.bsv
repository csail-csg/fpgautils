
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

import FpuTestRequest::*;
import FpuTestIndication::*;

import HostInterface::*;

import Clocks::*;
import GetPut::*;
import Connectable::*;

import UserClkRst::*;
import SyncFifo::*;
import FpuTestIF::*;
import FpuTest::*;

interface FpuTestWrapper;
    interface FpuTestRequest request;
endinterface

module mkFpuTestWrapper#(FpuTestIndication indication)(FpuTestWrapper);
    Clock portalClk <- exposeCurrentClock;
    Reset portalRst <- exposeCurrentReset;

`ifndef BSIM
    // user clock
    UserClkRst userClkRst <- mkUserClkRst(`USER_CLK_PERIOD);
    Clock userClk = userClkRst.clk;
    Reset userRst = userClkRst.rst;
`else
    Clock userClk = portalClk;
    Reset userRst = portalRst;
`endif

    FpuTest xilinxTest <- mkXilinxFpuTest(clocked_by userClk, reset_by userRst);
    FpuTest bluespecTest <- mkBluespecFpuTest(clocked_by userClk, reset_by userRst);

    // sync req
    SyncFIFOIfc#(TestReq) reqQ <- mkSyncFifo(1, portalClk, portalRst, userClk, userRst);

    rule sendReq;
        reqQ.deq;
        let r = reqQ.first;
        xilinxTest.req(r);
        bluespecTest.req(r);
    endrule

    // sync resp
    SyncFIFOIfc#(Tuple2#(AllResults, AllResults)) respQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);

    rule syncResp;
        let xilinxRes <- xilinxTest.resp;
        let bluespecRes <- bluespecTest.resp;
        respQ.enq(tuple2(xilinxRes, bluespecRes));
    endrule

    rule doResp;
        respQ.deq;
        let {x, b} = respQ.first;
        indication.resp(x, b);
    endrule

    interface FpuTestRequest request;
        method Action req(TestReq r);
            reqQ.enq(r);
        endmethod
    endinterface
endmodule
