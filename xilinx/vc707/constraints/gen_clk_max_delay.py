#!/usr/bin/python

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


delay_ratio = '$delay_ratio'
clk_names = ['$portal_clk', '$derived_clk', '$clk_125M', '$clk_250M_1', '$clk_250M_2']

for i in xrange(0, len(clk_names)):
    for j in xrange(i+1, len(clk_names)):
        src = clk_names[i]
        dst = clk_names[j]
        print ('set_max_delay -from [get_clocks {0}] -to [get_clocks {1}] -datapath_only ' + 
                '[expr $delay_ratio * [get_property PERIOD [get_clocks {1}]]]').format(src, dst)
        print ('set_max_delay -from [get_clocks {0}] -to [get_clocks {1}] -datapath_only ' + 
                '[expr $delay_ratio * [get_property PERIOD [get_clocks {1}]]]').format(dst, src)
        print ''
