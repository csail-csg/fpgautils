import Clocks::*;
import DDR3Common::*;
import DDR3Import::*;
import DDR3Utils::*;

export mkDDR3_1GB_Controller;

module mkDDR3_1GB_Controller#(
    Clock sys_clk, Reset sys_rst_n,
    DDR3_Controller_Config cfg
)(
    DDR3_1GB_Controller#(maxReadNum, simDelay)
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
        ddr3Ifc.app, user_clk, user_rst_n, cfg,
        clocked_by app_clock, reset_by app_reset_n
    );

    interface ddr3 = ddr3Ifc.ddr3;
    interface user = userIfc;
`else
    // simulation
    DDR3_1GB_User#(maxReadNum, simDelay) userIfc <- mkDDR3User_bsim;
    interface user = userIfc;
`endif
endmodule

