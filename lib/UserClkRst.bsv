
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
import Real::*;
import XilinxCells::*;
import ConnectalClocks::*;

interface UserClkRst;
    interface Clock clk;
    interface Reset rst;
endinterface

// this module generates user design clock from pcie portal clock (main clock)
// this module should be clocked under pcie portal clock
// period_ns is the period of the generated user clock in ns
module mkUserClkRst#(Integer period_ns)(UserClkRst);

    if(ceil(mainClockPeriod) != floor(mainClockPeriod)) begin
        errorM("Portal clock period (ns) is not integer!\n");
    end
    
    ClockGeneratorParams clkParams = defaultValue;
    clkParams.clkin1_period = mainClockPeriod;
    clkParams.clkin_buffer = False; // portal clock already buffered
    clkParams.reset_stages = 0; // directly using the current reset is fine
    clkParams.feedback_mul = floor(mainClockPeriod); // VCO is 1GHz
    clkParams.clk0_div = period_ns;

    // XXX name appears in XDC, don't change!
    // (get a name that won't mess up with Connectal PLL/MMCM names)
    ClockGenerator userClkGenerator <- mkClockGenerator(clkParams);

    Clock userClk = userClkGenerator.clkout0;
    Reset userRst <- mkAsyncResetFromCR(10, userClk);
    
    interface clk = userClk;
    interface rst = userRst;
endmodule
