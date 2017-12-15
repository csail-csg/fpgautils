
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

import Clocks::*;
import DefaultValue::*;

import SyncTestCommon::*;
import SyncTestIF::*;
import SyncTest::*;

import SyncTestRequest::*;
import SyncTestIndication::*;

import HostInterface::*;
import ConnectalClocks::*;

import UserClkRst::*;

interface SyncTestWrapper;
    interface SyncTestRequest request;
endinterface

module mkSyncTestWrapper#(HostInterface host, SyncTestIndication indication)(SyncTestWrapper);
    // clock of connections to host
    Clock portalClk <- exposeCurrentClock;
    Reset portalRst <- exposeCurrentReset;

`ifndef BSIM
    UserClkRst userClkRst <- mkUserClkRst(`USER_CLK_PERIOD);
    Clock userClk = userClkRst.clk;
    Reset userRst = userClkRst.rst;
`else
    Clock userClk = portalClk;
    Reset userRst = portalRst;
`endif

    SyncTest test <- mkSyncTest(portalClk, portalRst, clocked_by userClk, reset_by userRst);

    rule doDone;
        let r <- test.done;
        indication.done(r.logFifoSz, r.totalTime);
    endrule

    rule doErr;
        let r <- test.err;
        indication.done(r.logFifoSz, r.recvNum);
    endrule

    interface SyncTestRequest request;
        method start = test.start;
    endinterface
endmodule
