
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

# [sizhuo] constraints related to some connectal clocks
# these clocks should be auto-created by Vivado

set delay_ratio 1

# portal clk (fast clock)
set portal_clk [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clkgen_pll/CLKOUT1]]
# user clk (slow clk)
set user_clk [get_clocks -of_objects [get_pins -hier -filter {NAME =~ *userClkGenerator_pll/CLKOUT0}]]

# relations between clocks
set_max_delay -from [get_clocks $user_clk] -to [get_clocks $portal_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $portal_clk]]]
set_max_delay -from [get_clocks $portal_clk] -to [get_clocks $user_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $user_clk]]]

