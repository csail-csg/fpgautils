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
