import Clocks::*;
import DDR3Common::*;

// this module should be clocked by sys_clk_i, and reset by sys_rst (negative edge)
import "BVI" ddr3_wrapper =
module mkDDR3_1GB_Xilinx(DDR3_1GB_Xilinx);
    default_clock clk(sys_clk_i);
    default_reset rst(sys_rst);
    
    interface DDR3_1GB_Pins ddr3;
        ifc_inout dq(ddr3_dq)          clocked_by(no_clock)  reset_by(no_reset);
        ifc_inout dqs_p(ddr3_dqs_p)    clocked_by(no_clock)  reset_by(no_reset);
        ifc_inout dqs_n(ddr3_dqs_n)    clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_ck_p    clk_p   clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_ck_n    clk_n   clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_cke     cke     clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_cs_n    cs_n    clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_ras_n   ras_n   clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_cas_n   cas_n   clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_we_n    we_n    clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_reset_n reset_n clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_dm      dm      clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_ba      ba      clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_addr    a       clocked_by(no_clock)  reset_by(no_reset);
        method    ddr3_odt     odt     clocked_by(no_clock)  reset_by(no_reset);
    endinterface
    
    interface DDR3_1GB_App app;
        output_clock               clock(ui_clk);
        output_reset               reset(ui_clk_sync_rst);
        method init_calib_complete init_done clocked_by(app_clock) reset_by(no_reset);
        method                     app_addr(app_addr) enable((*inhigh*)en0) clocked_by(app_clock) reset_by(no_reset);
        method                     app_cmd(app_cmd)   enable((*inhigh*)en00) clocked_by(app_clock) reset_by(no_reset);
        method                     app_en(app_en)     enable((*inhigh*)en1) clocked_by(app_clock) reset_by(no_reset);
        method                     app_wdf_data(app_wdf_data) enable((*inhigh*)en2) clocked_by(app_clock) reset_by(no_reset);
        method                     app_wdf_end(app_wdf_end)   enable((*inhigh*)en3) clocked_by(app_clock) reset_by(no_reset);
        method                     app_wdf_mask(app_wdf_mask) enable((*inhigh*)en4) clocked_by(app_clock) reset_by(no_reset);
        method                     app_wdf_wren(app_wdf_wren) enable((*inhigh*)en5) clocked_by(app_clock) reset_by(no_reset);
        method app_rd_data         app_rd_data       clocked_by(app_clock) reset_by(no_reset);
        method app_rd_data_end     app_rd_data_end   clocked_by(app_clock) reset_by(no_reset);
        method app_rd_data_valid   app_rd_data_valid clocked_by(app_clock) reset_by(no_reset);
        method app_rdy             app_rdy     clocked_by(app_clock) reset_by(no_reset);
        method app_wdf_rdy         app_wdf_rdy clocked_by(app_clock) reset_by(no_reset);
    endinterface
    
    schedule
    (
     ddr3_clk_p, ddr3_clk_n, ddr3_cke, ddr3_cs_n, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, 
     ddr3_reset_n, ddr3_dm, ddr3_ba, ddr3_a, ddr3_odt
     )
    CF
    (
     ddr3_clk_p, ddr3_clk_n, ddr3_cke, ddr3_cs_n, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, 
     ddr3_reset_n, ddr3_dm, ddr3_ba, ddr3_a, ddr3_odt
     );
    
    schedule 
    (
     app_app_addr, app_app_en, app_app_wdf_data, app_app_wdf_end, app_app_wdf_mask, app_app_wdf_wren, app_app_rd_data, 
     app_app_rd_data_end, app_app_rd_data_valid, app_app_rdy, app_app_wdf_rdy, app_app_cmd, app_init_done
     )
    CF
    (
     app_app_addr, app_app_en, app_app_wdf_data, app_app_wdf_end, app_app_wdf_mask, app_app_wdf_wren, app_app_rd_data, 
     app_app_rd_data_end, app_app_rd_data_valid, app_app_rdy, app_app_wdf_rdy, app_app_cmd, app_init_done
     );

endmodule

// this module should be clocked by sys_clk_i, and reset by sys_rst (negative edge)
// FIXME: [sizhuo] unfortunately I cannot get 800MHz DDR3 timing closure...
//import "BVI" ddr3_1GB_800MHz_wrapper =
//module mkDDR3_1GB_Xilinx(DDR3_1GB_Xilinx);
//    default_clock clk(sys_clk_i);
//    default_reset rst(sys_rst);
//    
//    interface DDR3_1GB_Pins ddr3;
//        ifc_inout dq(ddr3_dq)          clocked_by(no_clock)  reset_by(no_reset);
//        ifc_inout dqs_p(ddr3_dqs_p)    clocked_by(no_clock)  reset_by(no_reset);
//        ifc_inout dqs_n(ddr3_dqs_n)    clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_ck_p    clk_p   clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_ck_n    clk_n   clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_cke     cke     clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_cs_n    cs_n    clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_ras_n   ras_n   clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_cas_n   cas_n   clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_we_n    we_n    clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_reset_n reset_n clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_dm      dm      clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_ba      ba      clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_addr    a       clocked_by(no_clock)  reset_by(no_reset);
//        method    ddr3_odt     odt     clocked_by(no_clock)  reset_by(no_reset);
//    endinterface
//    
//    interface DDR3_1GB_App app;
//        output_clock               clock(ui_clk);
//        output_reset               reset(ui_clk_sync_rst);
//        method init_calib_complete init_done clocked_by(no_clock) reset_by(no_reset);
//        method                     app_addr(app_addr) enable((*inhigh*)en0) clocked_by(app_clock) reset_by(no_reset);
//        method                     app_cmd(app_cmd)   enable((*inhigh*)en00) clocked_by(app_clock) reset_by(no_reset);
//        method                     app_en(app_en)     enable((*inhigh*)en1) clocked_by(app_clock) reset_by(no_reset);
//        method                     app_wdf_data(app_wdf_data) enable((*inhigh*)en2) clocked_by(app_clock) reset_by(no_reset);
//        method                     app_wdf_end(app_wdf_end)   enable((*inhigh*)en3) clocked_by(app_clock) reset_by(no_reset);
//        method                     app_wdf_mask(app_wdf_mask) enable((*inhigh*)en4) clocked_by(app_clock) reset_by(no_reset);
//        method                     app_wdf_wren(app_wdf_wren) enable((*inhigh*)en5) clocked_by(app_clock) reset_by(no_reset);
//        method app_rd_data         app_rd_data       clocked_by(app_clock) reset_by(no_reset);
//        method app_rd_data_end     app_rd_data_end   clocked_by(app_clock) reset_by(no_reset);
//        method app_rd_data_valid   app_rd_data_valid clocked_by(app_clock) reset_by(no_reset);
//        method app_rdy             app_rdy     clocked_by(app_clock) reset_by(no_reset);
//        method app_wdf_rdy         app_wdf_rdy clocked_by(app_clock) reset_by(no_reset);
//    endinterface
//    
//    schedule
//    (
//     ddr3_clk_p, ddr3_clk_n, ddr3_cke, ddr3_cs_n, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, 
//     ddr3_reset_n, ddr3_dm, ddr3_ba, ddr3_a, ddr3_odt, app_init_done
//     )
//    CF
//    (
//     ddr3_clk_p, ddr3_clk_n, ddr3_cke, ddr3_cs_n, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, 
//     ddr3_reset_n, ddr3_dm, ddr3_ba, ddr3_a, ddr3_odt, app_init_done
//     );
//    
//    schedule 
//    (
//     app_app_addr, app_app_en, app_app_wdf_data, app_app_wdf_end, app_app_wdf_mask, app_app_wdf_wren, app_app_rd_data, 
//     app_app_rd_data_end, app_app_rd_data_valid, app_app_rdy, app_app_wdf_rdy, app_app_cmd
//     )
//    CF
//    (
//     app_app_addr, app_app_en, app_app_wdf_data, app_app_wdf_end, app_app_wdf_mask, app_app_wdf_wren, app_app_rd_data, 
//     app_app_rd_data_end, app_app_rd_data_valid, app_app_rdy, app_app_wdf_rdy, app_app_cmd
//     );
//
//endmodule
