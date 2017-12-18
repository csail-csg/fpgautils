
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

import DSTestRequest::*;
import DSTestIndication::*;

import HostInterface::*;

import Clocks::*;
import GetPut::*;
import Connectable::*;

import DSTestIF::*;
import DSTest::*;
import UserClkRst::*;
import SyncFifo::*;
import DramCommon::*;
import DDR3Common::*;
import AWSDramCommon::*;

import DDR3Wrapper::*;
import AWSDramWrapper::*;

`ifdef TEST_VC707
typedef DDR3Err DramErr;
typedef DDR3UserWrapper DramUserWrapper;
typedef DDR3FullWrapper DramFullWrapper;
typedef DDR3_1GB_Pins DramPins;
`endif
`ifdef TEST_AWSF1
typedef AWSDramErr DramErr;
typedef AWSDramUserWrapper DramUserWrapper;
typedef AWSDramFullWrapper DramFullWrapper;
typedef AWSDramPins DramPins;
`endif

interface DSTestWrapper;
    interface DSTestRequest request;
`ifndef BSIM
    interface DramPins pins;
`endif
endinterface

module mkDSTestWrapper#(HostInterface host, DSTestIndication indication)(DSTestWrapper);
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

    // instantiate Dram
`ifdef TEST_VC707
    Clock sys_clk = host.tsys_clk_200mhz_buf;
    Reset sys_rst_n <- mkAsyncResetFromCR(4, sys_clk);
    DramFullWrapper dram <- mkDDR3Wrapper(
        sys_clk, sys_rst_n, clocked_by userClk, reset_by userRst
    );
`endif
`ifdef TEST_AWSF1
    DramFullWrapper dram <- mkAWSDramWrapper(
        portalClk, portalRst, clocked_by userClk, reset_by userRst
    );
`endif

    // user test
    DSTest test <- mkDSTest(
        portalClk, portalRst, clocked_by userClk, reset_by userRst
    );

    // connect to DDR3
    mkConnection(test.dramReq, dram.user.req);
    mkConnection(test.dramResp, dram.user.rdResp);

    // connect indication
    rule doDone;
        DoneResp r <- test.done;
        indication.done(r.testId, r.wrTime, r.rdTime, r.rdLatSum);
    endrule

    rule doReadErr;
        ErrResp r <- test.err;
        indication.readErr(r.testId, r.rdAddr);
    endrule

    SyncFIFOIfc#(DramErr) dramErrQ <- mkSyncFifo(1, userClk, userRst, portalClk, portalRst);
    mkConnection(toPut(dramErrQ).put, dram.user.err);
    rule doDramErr;
        DramErr e <- toGet(dramErrQ).get;
        indication.dramErr(zeroExtend(pack(e)));
    endrule

    // indication can only be sent after connectal is inited (i.e. after start req)
    Reg#(Bool) inited <- mkReg(False);

`ifndef BSIM
    interface pins = dram.pins;
`endif
    interface DSTestRequest request;
        method Action start(Bit#(32) num) if(!inited);
            test.start(num);
            inited <= True;
        endmethod
    endinterface
endmodule
