
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

import DramCommon::*;
import DDR3Common::*;
import DDR3Import::*;
import DDR3Utils::*;

export mkDDR3_1GB_Controller;

module mkDDR3_1GB_Controller#(
    Clock sys_clk, Reset sys_rst_n,
    Bool useBramRespBuffer
)(
    DDR3_1GB_Full#(maxReadNum, simDelay)
) provisos (
    Add#(1, a__, maxReadNum),
    Add#(1, b__, simDelay)
);
`ifndef BSIM
    // FPGA
    DDR3_1GB_Xilinx ddr3Ifc <- mkDDR3_1GB_Xilinx(clocked_by sys_clk, reset_by sys_rst_n);

    // Xilinx App ifc clock & invert of reset (Xilinx app reset is pos-edge)
    Clock app_clock     = ddr3Ifc.app.clock;
    Reset app_reset0_n <- mkResetInverter(ddr3Ifc.app.reset);
    Reset app_reset_n  <- mkAsyncReset(4, app_reset0_n, app_clock);

    // user clock & rst
    Clock user_clk <- exposeCurrentClock;
    Reset user_rst_n <- exposeCurrentReset;
    
    DDR3_1GB_User#(maxReadNum, simDelay) userIfc <- mkDDR3User_2beats(
        ddr3Ifc.app, user_clk, user_rst_n, useBramRespBuffer,
        clocked_by app_clock, reset_by app_reset_n
    );

    interface user = userIfc;
    interface pins = ddr3Ifc.ddr3;
`else
    // simulation
    DDR3_1GB_User#(maxReadNum, simDelay) userIfc <- mkDDR3User_bsim;
    interface user = userIfc;
    interface Empty pins;
    endinterface
`endif
endmodule

