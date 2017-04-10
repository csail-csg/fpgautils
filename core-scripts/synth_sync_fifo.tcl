source board.tcl
source $connectaldir/scripts/connectal-synth-ip.tcl

connectal_synth_ip fifo_generator 13.0 sync_fifo_w32_d16 [list \
    CONFIG.Fifo_Implementation {Independent_Clocks_Distributed_RAM} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
    CONFIG.Input_Data_Width {32} \
    CONFIG.Input_Depth {16} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Output_Depth {16} \
    CONFIG.Reset_Pin {false}]
