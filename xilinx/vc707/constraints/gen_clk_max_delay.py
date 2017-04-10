#!/usr/bin/python
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
