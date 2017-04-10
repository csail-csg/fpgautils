# [sizhuo] constraints related to some connectal clocks
# these clocks should be auto-created by Vivado
# modified from xushuotao/bluecache/constraints/clocks.xdc

set delay_ratio 1

# clkgen_pll
# portal clk (major design clk)
set portal_clk [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clkgen_pll/CLKOUT1]]
# derived clk
set derived_clk [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clkgen_pll/CLKOUT0]]

# clockGen_pll
# 250MHz clks
set clk_250M_1 [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clockGen_pll/CLKOUT1]]
set clk_250M_2 [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clockGen_pll/CLKOUT2]]
# 125MHz clk
set clk_125M [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clockGen_pll/CLKOUT0]]

# relations between clocks
set_max_delay -from [get_clocks $portal_clk] -to [get_clocks $derived_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $derived_clk]]]
set_max_delay -from [get_clocks $derived_clk] -to [get_clocks $portal_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $portal_clk]]]

set_max_delay -from [get_clocks $portal_clk] -to [get_clocks $clk_125M] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_125M]]]
set_max_delay -from [get_clocks $clk_125M] -to [get_clocks $portal_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $portal_clk]]]

set_max_delay -from [get_clocks $portal_clk] -to [get_clocks $clk_250M_1] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_1]]]
set_max_delay -from [get_clocks $clk_250M_1] -to [get_clocks $portal_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $portal_clk]]]

set_max_delay -from [get_clocks $portal_clk] -to [get_clocks $clk_250M_2] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_2]]]
set_max_delay -from [get_clocks $clk_250M_2] -to [get_clocks $portal_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $portal_clk]]]

set_max_delay -from [get_clocks $derived_clk] -to [get_clocks $clk_125M] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_125M]]]
set_max_delay -from [get_clocks $clk_125M] -to [get_clocks $derived_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $derived_clk]]]

set_max_delay -from [get_clocks $derived_clk] -to [get_clocks $clk_250M_1] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_1]]]
set_max_delay -from [get_clocks $clk_250M_1] -to [get_clocks $derived_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $derived_clk]]]

set_max_delay -from [get_clocks $derived_clk] -to [get_clocks $clk_250M_2] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_2]]]
set_max_delay -from [get_clocks $clk_250M_2] -to [get_clocks $derived_clk] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $derived_clk]]]

set_max_delay -from [get_clocks $clk_125M] -to [get_clocks $clk_250M_1] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_1]]]
set_max_delay -from [get_clocks $clk_250M_1] -to [get_clocks $clk_125M] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_125M]]]

set_max_delay -from [get_clocks $clk_125M] -to [get_clocks $clk_250M_2] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_2]]]
set_max_delay -from [get_clocks $clk_250M_2] -to [get_clocks $clk_125M] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_125M]]]

set_max_delay -from [get_clocks $clk_250M_1] -to [get_clocks $clk_250M_2] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_2]]]
set_max_delay -from [get_clocks $clk_250M_2] -to [get_clocks $clk_250M_1] -datapath_only [expr $delay_ratio * [get_property PERIOD [get_clocks $clk_250M_1]]]

