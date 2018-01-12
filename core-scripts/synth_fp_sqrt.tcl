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

if {$::argc != 2} {
    error "Usage: $::argv0 LATENCY RATE"
} else {
    set ip_lat [lindex $argv 0]
    set ip_rate [lindex $argv 1]
}
puts "Latency $ip_lat Rate $ip_rate"

connectal_synth_ip floating_point 7.1 fp_sqrt [list \
    CONFIG.A_Precision_Type {Double} \
    CONFIG.Add_Sub_Value {Both} \
    CONFIG.Axi_Optimize_Goal {Resources} \
    CONFIG.C_A_Exponent_Width {11} \
    CONFIG.C_A_Fraction_Width {53} \
    CONFIG.C_Accum_Input_Msb {32} \
    CONFIG.C_Accum_Lsb {-31} \
    CONFIG.C_Accum_Msb {32} \
    CONFIG.C_Has_INVALID_OP {true} \
    CONFIG.C_Latency $ip_lat \
    CONFIG.C_Mult_Usage {No_Usage} \
    CONFIG.C_Rate $ip_rate \
    CONFIG.C_Result_Exponent_Width {11} \
    CONFIG.C_Result_Fraction_Width {53} \
    CONFIG.Flow_Control {Blocking} \
    CONFIG.Has_A_TLAST {false} \
    CONFIG.Has_RESULT_TREADY {true} \
    CONFIG.Maximum_Latency {false} \
    CONFIG.Operation_Type {Square_root} \
    CONFIG.RESULT_TLAST_Behv {Null} \
    CONFIG.Result_Precision_Type {Double}]
