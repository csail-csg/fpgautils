# Copyright (c) 2017 Massachusetts Institute of Technology
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

source board.tcl
source $connectaldir/scripts/connectal-synth-ip.tcl

set sync_fifo_version {13.0}
if {[version -short] >= "2016.4"} {
    set sync_fifo_version {13.1}
}
if {[version -short] >= "2017.4"} {
    set sync_fifo_version {13.2}
}

connectal_synth_ip fifo_generator $sync_fifo_version sync_fifo_w32_d16 [list \
    CONFIG.Fifo_Implementation {Independent_Clocks_Distributed_RAM} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
    CONFIG.Input_Data_Width {32} \
    CONFIG.Input_Depth {16} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Output_Depth {16} \
    CONFIG.Reset_Pin {false}]
