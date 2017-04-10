source board.tcl
source $connectaldir/scripts/connectal-synth-ip.tcl

connectal_synth_ip fifo_generator 13.0 sync_bram_fifo_w36_d512 [list \
    CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
    CONFIG.Input_Data_Width {36} \
    CONFIG.Input_Depth {512} \
    CONFIG.Output_Data_Width {36} \
    CONFIG.Output_Depth {512} \
    CONFIG.Reset_Pin {false}]
