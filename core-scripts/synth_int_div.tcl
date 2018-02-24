
source board.tcl
source $connectaldir/scripts/connectal-synth-ip.tcl

if {$::argc != 1} {
    error "Usage: $::argv0 LATENCY"
} else {
    set ip_lat [lindex $argv 0]
}
puts "Latency $ip_lat"

connectal_synth_ip div_gen 5.1 int_div_unsigned [list \
    CONFIG.FlowControl {Blocking} \
    CONFIG.OptimizeGoal {Resources} \
    CONFIG.OutTready {true} \
    CONFIG.dividend_and_quotient_width {64} \
    CONFIG.dividend_has_tuser {true} \
    CONFIG.dividend_tuser_width {76} \
    CONFIG.divisor_width {64} \
    CONFIG.fractional_width {64} \
    CONFIG.latency $ip_lat \
    CONFIG.latency_configuration {Manual} \
    CONFIG.operand_sign {Unsigned}]
