
// This module outputs a 1-bit signal
// The signal is initially 0 after programming the FPGA
// XXX: hopefully everything is inited to 0 after programming

// When a reset arrives, the module starts counting
// In N cycles after the reset, the signal becomes 1 
// This signal can be used as a guard for sync fifo operations

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module reset_guard(
    input CLK,
    input RST,
    output IS_READY
);
    reg ready = 0;
    reg rst_done = 0;

    always@(posedge CLK) begin
        if(RST == `BSV_RESET_VALUE) begin
            ready <= 0;
            rst_done <= 1;
            // synopsys translate_off
            if(!rst_done) begin
                $display("[reset_guard] %t %m reset happen", $time);
            end
            // synopsys translate_on
        end
        else if(rst_done) begin
            ready <= 1;
            // synopsys translate_off
            if(!ready) begin
                $display("[reset_guard] %t %m guard ready", $time);
            end
            // synopsys translate_on
        end
    end

    assign IS_READY = ready;
endmodule
