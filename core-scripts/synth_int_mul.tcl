
source board.tcl
source $connectaldir/scripts/connectal-synth-ip.tcl

if {$::argc != 1} {
    error "Usage: $::argv0 LATENCY"
} else {
    set ip_lat [lindex $argv 0]
}
puts "Latency $ip_lat"

connectal_synth_ip mult_gen 12.0 int_mul_signed [list \
    CONFIG.Multiplier_Construction {Use_Mults} \
    CONFIG.OutputWidthHigh {127} \
    CONFIG.PipeStages $ip_lat \
    CONFIG.PortAWidth {64} \
    CONFIG.PortBWidth {64}]

connectal_synth_ip mult_gen 12.0 int_mul_unsigned [list \
    CONFIG.Multiplier_Construction {Use_Mults} \
    CONFIG.OutputWidthHigh {127} \
    CONFIG.PipeStages $ip_lat \
    CONFIG.PortAType {Unsigned} \
    CONFIG.PortAWidth {64} \
    CONFIG.PortBType {Unsigned} \
    CONFIG.PortBWidth {64}]

connectal_synth_ip mult_gen 12.0 int_mul_signed_unsigned [list \
    CONFIG.Multiplier_Construction {Use_Mults} \
    CONFIG.OutputWidthHigh {127} \
    CONFIG.PipeStages $ip_lat \
    CONFIG.PortAWidth {64} \
    CONFIG.PortBType {Unsigned} \
    CONFIG.PortBWidth {64}]
