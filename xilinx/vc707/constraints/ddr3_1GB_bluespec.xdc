######################################################################################################
##  DDR3 Constraints
######################################################################################################
# [sizhuo] modifed from Bluespec

######################################################################################################
# PIN ASSIGNMENTS
######################################################################################################
# PadFunction: IO_L23N_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[0]}]
set_property SLEW FAST [get_ports {DDR3_DQ[0]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[0]}]
set_property PACKAGE_PIN N14 [get_ports {DDR3_DQ[0]}]

# PadFunction: IO_L22P_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[1]}]
set_property SLEW FAST [get_ports {DDR3_DQ[1]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[1]}]
set_property PACKAGE_PIN N13 [get_ports {DDR3_DQ[1]}]

# PadFunction: IO_L20N_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[2]}]
set_property SLEW FAST [get_ports {DDR3_DQ[2]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[2]}]
set_property PACKAGE_PIN L14 [get_ports {DDR3_DQ[2]}]

# PadFunction: IO_L20P_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[3]}]
set_property SLEW FAST [get_ports {DDR3_DQ[3]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[3]}]
set_property PACKAGE_PIN M14 [get_ports {DDR3_DQ[3]}]

# PadFunction: IO_L24P_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[4]}]
set_property SLEW FAST [get_ports {DDR3_DQ[4]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[4]}]
set_property PACKAGE_PIN M12 [get_ports {DDR3_DQ[4]}]

# PadFunction: IO_L23P_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[5]}]
set_property SLEW FAST [get_ports {DDR3_DQ[5]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[5]}]
set_property PACKAGE_PIN N15 [get_ports {DDR3_DQ[5]}]

# PadFunction: IO_L24N_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[6]}]
set_property SLEW FAST [get_ports {DDR3_DQ[6]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[6]}]
set_property PACKAGE_PIN M11 [get_ports {DDR3_DQ[6]}]

# PadFunction: IO_L19P_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[7]}]
set_property SLEW FAST [get_ports {DDR3_DQ[7]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[7]}]
set_property PACKAGE_PIN L12 [get_ports {DDR3_DQ[7]}]

# PadFunction: IO_L17P_T2_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[8]}]
set_property SLEW FAST [get_ports {DDR3_DQ[8]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[8]}]
set_property PACKAGE_PIN K14 [get_ports {DDR3_DQ[8]}]

# PadFunction: IO_L17N_T2_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[9]}]
set_property SLEW FAST [get_ports {DDR3_DQ[9]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[9]}]
set_property PACKAGE_PIN K13 [get_ports {DDR3_DQ[9]}]

# PadFunction: IO_L14N_T2_SRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[10]}]
set_property SLEW FAST [get_ports {DDR3_DQ[10]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[10]}]
set_property PACKAGE_PIN H13 [get_ports {DDR3_DQ[10]}]

# PadFunction: IO_L14P_T2_SRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[11]}]
set_property SLEW FAST [get_ports {DDR3_DQ[11]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[11]}]
set_property PACKAGE_PIN J13 [get_ports {DDR3_DQ[11]}]

# PadFunction: IO_L18P_T2_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[12]}]
set_property SLEW FAST [get_ports {DDR3_DQ[12]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[12]}]
set_property PACKAGE_PIN L16 [get_ports {DDR3_DQ[12]}]

# PadFunction: IO_L18N_T2_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[13]}]
set_property SLEW FAST [get_ports {DDR3_DQ[13]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[13]}]
set_property PACKAGE_PIN L15 [get_ports {DDR3_DQ[13]}]

# PadFunction: IO_L13N_T2_MRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[14]}]
set_property SLEW FAST [get_ports {DDR3_DQ[14]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[14]}]
set_property PACKAGE_PIN H14 [get_ports {DDR3_DQ[14]}]

# PadFunction: IO_L16N_T2_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[15]}]
set_property SLEW FAST [get_ports {DDR3_DQ[15]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[15]}]
set_property PACKAGE_PIN J15 [get_ports {DDR3_DQ[15]}]

# PadFunction: IO_L7N_T1_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[16]}]
set_property SLEW FAST [get_ports {DDR3_DQ[16]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[16]}]
set_property PACKAGE_PIN E15 [get_ports {DDR3_DQ[16]}]

# PadFunction: IO_L8N_T1_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[17]}]
set_property SLEW FAST [get_ports {DDR3_DQ[17]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[17]}]
set_property PACKAGE_PIN E13 [get_ports {DDR3_DQ[17]}]

# PadFunction: IO_L11P_T1_SRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[18]}]
set_property SLEW FAST [get_ports {DDR3_DQ[18]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[18]}]
set_property PACKAGE_PIN F15 [get_ports {DDR3_DQ[18]}]

# PadFunction: IO_L8P_T1_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[19]}]
set_property SLEW FAST [get_ports {DDR3_DQ[19]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[19]}]
set_property PACKAGE_PIN E14 [get_ports {DDR3_DQ[19]}]

# PadFunction: IO_L12N_T1_MRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[20]}]
set_property SLEW FAST [get_ports {DDR3_DQ[20]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[20]}]
set_property PACKAGE_PIN G13 [get_ports {DDR3_DQ[20]}]

# PadFunction: IO_L10P_T1_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[21]}]
set_property SLEW FAST [get_ports {DDR3_DQ[21]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[21]}]
set_property PACKAGE_PIN G12 [get_ports {DDR3_DQ[21]}]

# PadFunction: IO_L11N_T1_SRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[22]}]
set_property SLEW FAST [get_ports {DDR3_DQ[22]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[22]}]
set_property PACKAGE_PIN F14 [get_ports {DDR3_DQ[22]}]

# PadFunction: IO_L12P_T1_MRCC_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[23]}]
set_property SLEW FAST [get_ports {DDR3_DQ[23]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[23]}]
set_property PACKAGE_PIN G14 [get_ports {DDR3_DQ[23]}]

# PadFunction: IO_L2P_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[24]}]
set_property SLEW FAST [get_ports {DDR3_DQ[24]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[24]}]
set_property PACKAGE_PIN B14 [get_ports {DDR3_DQ[24]}]

# PadFunction: IO_L4N_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[25]}]
set_property SLEW FAST [get_ports {DDR3_DQ[25]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[25]}]
set_property PACKAGE_PIN C13 [get_ports {DDR3_DQ[25]}]

# PadFunction: IO_L1N_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[26]}]
set_property SLEW FAST [get_ports {DDR3_DQ[26]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[26]}]
set_property PACKAGE_PIN B16 [get_ports {DDR3_DQ[26]}]

# PadFunction: IO_L5N_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[27]}]
set_property SLEW FAST [get_ports {DDR3_DQ[27]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[27]}]
set_property PACKAGE_PIN D15 [get_ports {DDR3_DQ[27]}]

# PadFunction: IO_L4P_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[28]}]
set_property SLEW FAST [get_ports {DDR3_DQ[28]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[28]}]
set_property PACKAGE_PIN D13 [get_ports {DDR3_DQ[28]}]

# PadFunction: IO_L6P_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[29]}]
set_property SLEW FAST [get_ports {DDR3_DQ[29]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[29]}]
set_property PACKAGE_PIN E12 [get_ports {DDR3_DQ[29]}]

# PadFunction: IO_L1P_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[30]}]
set_property SLEW FAST [get_ports {DDR3_DQ[30]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[30]}]
set_property PACKAGE_PIN C16 [get_ports {DDR3_DQ[30]}]

# PadFunction: IO_L5P_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[31]}]
set_property SLEW FAST [get_ports {DDR3_DQ[31]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[31]}]
set_property PACKAGE_PIN D16 [get_ports {DDR3_DQ[31]}]

# PadFunction: IO_L1P_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[32]}]
set_property SLEW FAST [get_ports {DDR3_DQ[32]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[32]}]
set_property PACKAGE_PIN A24 [get_ports {DDR3_DQ[32]}]

# PadFunction: IO_L4N_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[33]}]
set_property SLEW FAST [get_ports {DDR3_DQ[33]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[33]}]
set_property PACKAGE_PIN B23 [get_ports {DDR3_DQ[33]}]

# PadFunction: IO_L5N_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[34]}]
set_property SLEW FAST [get_ports {DDR3_DQ[34]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[34]}]
set_property PACKAGE_PIN B27 [get_ports {DDR3_DQ[34]}]

# PadFunction: IO_L5P_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[35]}]
set_property SLEW FAST [get_ports {DDR3_DQ[35]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[35]}]
set_property PACKAGE_PIN B26 [get_ports {DDR3_DQ[35]}]

# PadFunction: IO_L2N_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[36]}]
set_property SLEW FAST [get_ports {DDR3_DQ[36]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[36]}]
set_property PACKAGE_PIN A22 [get_ports {DDR3_DQ[36]}]

# PadFunction: IO_L2P_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[37]}]
set_property SLEW FAST [get_ports {DDR3_DQ[37]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[37]}]
set_property PACKAGE_PIN B22 [get_ports {DDR3_DQ[37]}]

# PadFunction: IO_L1N_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[38]}]
set_property SLEW FAST [get_ports {DDR3_DQ[38]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[38]}]
set_property PACKAGE_PIN A25 [get_ports {DDR3_DQ[38]}]

# PadFunction: IO_L6P_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[39]}]
set_property SLEW FAST [get_ports {DDR3_DQ[39]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[39]}]
set_property PACKAGE_PIN C24 [get_ports {DDR3_DQ[39]}]

# PadFunction: IO_L7N_T1_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[40]}]
set_property SLEW FAST [get_ports {DDR3_DQ[40]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[40]}]
set_property PACKAGE_PIN E24 [get_ports {DDR3_DQ[40]}]

# PadFunction: IO_L10N_T1_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[41]}]
set_property SLEW FAST [get_ports {DDR3_DQ[41]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[41]}]
set_property PACKAGE_PIN D23 [get_ports {DDR3_DQ[41]}]

# PadFunction: IO_L11N_T1_SRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[42]}]
set_property SLEW FAST [get_ports {DDR3_DQ[42]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[42]}]
set_property PACKAGE_PIN D26 [get_ports {DDR3_DQ[42]}]

# PadFunction: IO_L12P_T1_MRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[43]}]
set_property SLEW FAST [get_ports {DDR3_DQ[43]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[43]}]
set_property PACKAGE_PIN C25 [get_ports {DDR3_DQ[43]}]

# PadFunction: IO_L7P_T1_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[44]}]
set_property SLEW FAST [get_ports {DDR3_DQ[44]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[44]}]
set_property PACKAGE_PIN E23 [get_ports {DDR3_DQ[44]}]

# PadFunction: IO_L10P_T1_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[45]}]
set_property SLEW FAST [get_ports {DDR3_DQ[45]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[45]}]
set_property PACKAGE_PIN D22 [get_ports {DDR3_DQ[45]}]

# PadFunction: IO_L8P_T1_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[46]}]
set_property SLEW FAST [get_ports {DDR3_DQ[46]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[46]}]
set_property PACKAGE_PIN F22 [get_ports {DDR3_DQ[46]}]

# PadFunction: IO_L8N_T1_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[47]}]
set_property SLEW FAST [get_ports {DDR3_DQ[47]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[47]}]
set_property PACKAGE_PIN E22 [get_ports {DDR3_DQ[47]}]

# PadFunction: IO_L17N_T2_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[48]}]
set_property SLEW FAST [get_ports {DDR3_DQ[48]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[48]}]
set_property PACKAGE_PIN A30 [get_ports {DDR3_DQ[48]}]

# PadFunction: IO_L13P_T2_MRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[49]}]
set_property SLEW FAST [get_ports {DDR3_DQ[49]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[49]}]
set_property PACKAGE_PIN D27 [get_ports {DDR3_DQ[49]}]

# PadFunction: IO_L17P_T2_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[50]}]
set_property SLEW FAST [get_ports {DDR3_DQ[50]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[50]}]
set_property PACKAGE_PIN A29 [get_ports {DDR3_DQ[50]}]

# PadFunction: IO_L14P_T2_SRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[51]}]
set_property SLEW FAST [get_ports {DDR3_DQ[51]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[51]}]
set_property PACKAGE_PIN C28 [get_ports {DDR3_DQ[51]}]

# PadFunction: IO_L13N_T2_MRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[52]}]
set_property SLEW FAST [get_ports {DDR3_DQ[52]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[52]}]
set_property PACKAGE_PIN D28 [get_ports {DDR3_DQ[52]}]

# PadFunction: IO_L18N_T2_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[53]}]
set_property SLEW FAST [get_ports {DDR3_DQ[53]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[53]}]
set_property PACKAGE_PIN B31 [get_ports {DDR3_DQ[53]}]

# PadFunction: IO_L16P_T2_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[54]}]
set_property SLEW FAST [get_ports {DDR3_DQ[54]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[54]}]
set_property PACKAGE_PIN A31 [get_ports {DDR3_DQ[54]}]

# PadFunction: IO_L16N_T2_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[55]}]
set_property SLEW FAST [get_ports {DDR3_DQ[55]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[55]}]
set_property PACKAGE_PIN A32 [get_ports {DDR3_DQ[55]}]

# PadFunction: IO_L19P_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[56]}]
set_property SLEW FAST [get_ports {DDR3_DQ[56]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[56]}]
set_property PACKAGE_PIN E30 [get_ports {DDR3_DQ[56]}]

# PadFunction: IO_L22P_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[57]}]
set_property SLEW FAST [get_ports {DDR3_DQ[57]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[57]}]
set_property PACKAGE_PIN F29 [get_ports {DDR3_DQ[57]}]

# PadFunction: IO_L24P_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[58]}]
set_property SLEW FAST [get_ports {DDR3_DQ[58]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[58]}]
set_property PACKAGE_PIN F30 [get_ports {DDR3_DQ[58]}]

# PadFunction: IO_L23N_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[59]}]
set_property SLEW FAST [get_ports {DDR3_DQ[59]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[59]}]
set_property PACKAGE_PIN F27 [get_ports {DDR3_DQ[59]}]

# PadFunction: IO_L20N_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[60]}]
set_property SLEW FAST [get_ports {DDR3_DQ[60]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[60]}]
set_property PACKAGE_PIN C30 [get_ports {DDR3_DQ[60]}]

# PadFunction: IO_L22N_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[61]}]
set_property SLEW FAST [get_ports {DDR3_DQ[61]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[61]}]
set_property PACKAGE_PIN E29 [get_ports {DDR3_DQ[61]}]

# PadFunction: IO_L23P_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[62]}]
set_property SLEW FAST [get_ports {DDR3_DQ[62]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[62]}]
set_property PACKAGE_PIN F26 [get_ports {DDR3_DQ[62]}]

# PadFunction: IO_L20P_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQ[63]}]
set_property SLEW FAST [get_ports {DDR3_DQ[63]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {DDR3_DQ[63]}]
set_property PACKAGE_PIN D30 [get_ports {DDR3_DQ[63]}]

# [sizhuo] addr 14,15 are not used
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[15]}]
#set_property SLEW FAST [get_ports {DDR3_A[15]}]
#set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[15]}]
#set_property PACKAGE_PIN E17 [get_ports {DDR3_A[15]}]

#set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[14]}]
#set_property SLEW FAST [get_ports {DDR3_A[14]}]
#set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[14]}]
#set_property PACKAGE_PIN F17 [get_ports {DDR3_A[14]}]

# PadFunction: IO_L5N_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[13]}]
set_property SLEW FAST [get_ports {DDR3_A[13]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[13]}]
set_property PACKAGE_PIN A21 [get_ports {DDR3_A[13]}]

# PadFunction: IO_L2N_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[12]}]
set_property SLEW FAST [get_ports {DDR3_A[12]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[12]}]
set_property PACKAGE_PIN A15 [get_ports {DDR3_A[12]}]

# PadFunction: IO_L4P_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[11]}]
set_property SLEW FAST [get_ports {DDR3_A[11]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[11]}]
set_property PACKAGE_PIN B17 [get_ports {DDR3_A[11]}]

# PadFunction: IO_L5P_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[10]}]
set_property SLEW FAST [get_ports {DDR3_A[10]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[10]}]
set_property PACKAGE_PIN B21 [get_ports {DDR3_A[10]}]

# PadFunction: IO_L1P_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[9]}]
set_property SLEW FAST [get_ports {DDR3_A[9]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[9]}]
set_property PACKAGE_PIN C19 [get_ports {DDR3_A[9]}]

# PadFunction: IO_L10N_T1_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[8]}]
set_property SLEW FAST [get_ports {DDR3_A[8]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[8]}]
set_property PACKAGE_PIN D17 [get_ports {DDR3_A[8]}]

# PadFunction: IO_L6P_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[7]}]
set_property SLEW FAST [get_ports {DDR3_A[7]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[7]}]
set_property PACKAGE_PIN C18 [get_ports {DDR3_A[7]}]

# PadFunction: IO_L7P_T1_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[6]}]
set_property SLEW FAST [get_ports {DDR3_A[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[6]}]
set_property PACKAGE_PIN D20 [get_ports {DDR3_A[6]}]

# PadFunction: IO_L2P_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[5]}]
set_property SLEW FAST [get_ports {DDR3_A[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[5]}]
set_property PACKAGE_PIN A16 [get_ports {DDR3_A[5]}]

# PadFunction: IO_L4N_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[4]}]
set_property SLEW FAST [get_ports {DDR3_A[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[4]}]
set_property PACKAGE_PIN A17 [get_ports {DDR3_A[4]}]

# PadFunction: IO_L3N_T0_DQS_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[3]}]
set_property SLEW FAST [get_ports {DDR3_A[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[3]}]
set_property PACKAGE_PIN A19 [get_ports {DDR3_A[3]}]

# PadFunction: IO_L7N_T1_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[2]}]
set_property SLEW FAST [get_ports {DDR3_A[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[2]}]
set_property PACKAGE_PIN C20 [get_ports {DDR3_A[2]}]

# PadFunction: IO_L1N_T0_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[1]}]
set_property SLEW FAST [get_ports {DDR3_A[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[1]}]
set_property PACKAGE_PIN B19 [get_ports {DDR3_A[1]}]

# PadFunction: IO_L3P_T0_DQS_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_A[0]}]
set_property SLEW FAST [get_ports {DDR3_A[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_A[0]}]
set_property PACKAGE_PIN A20 [get_ports {DDR3_A[0]}]

# PadFunction: IO_L10P_T1_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_BA[2]}]
set_property SLEW FAST [get_ports {DDR3_BA[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_BA[2]}]
set_property PACKAGE_PIN D18 [get_ports {DDR3_BA[2]}]

# PadFunction: IO_L9N_T1_DQS_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_BA[1]}]
set_property SLEW FAST [get_ports {DDR3_BA[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_BA[1]}]
set_property PACKAGE_PIN C21 [get_ports {DDR3_BA[1]}]

# PadFunction: IO_L9P_T1_DQS_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_BA[0]}]
set_property SLEW FAST [get_ports {DDR3_BA[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_BA[0]}]
set_property PACKAGE_PIN D21 [get_ports {DDR3_BA[0]}]

# PadFunction: IO_L15N_T2_DQS_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_RAS_N}]
set_property SLEW FAST [get_ports {DDR3_RAS_N}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_RAS_N}]
set_property PACKAGE_PIN E20 [get_ports {DDR3_RAS_N}]

# PadFunction: IO_L16P_T2_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_CAS_N}]
set_property SLEW FAST [get_ports {DDR3_CAS_N}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_CAS_N}]
set_property PACKAGE_PIN K17 [get_ports {DDR3_CAS_N}]

# PadFunction: IO_L15P_T2_DQS_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_WE_N}]
set_property SLEW FAST [get_ports {DDR3_WE_N}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_WE_N}]
set_property PACKAGE_PIN F20 [get_ports {DDR3_WE_N}]

# PadFunction: IO_L14N_T2_SRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_RESET_N}]
set_property SLEW FAST [get_ports {DDR3_RESET_N}]
set_property IOSTANDARD LVCMOS15 [get_ports {DDR3_RESET_N}]
set_property PACKAGE_PIN C29 [get_ports {DDR3_RESET_N}]

# PadFunction: IO_L14P_T2_SRCC_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_CKE}]
set_property SLEW FAST [get_ports {DDR3_CKE}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_CKE}]
set_property PACKAGE_PIN K19 [get_ports {DDR3_CKE}]

# PadFunction: IO_L17N_T2_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_ODT}]
set_property SLEW FAST [get_ports {DDR3_ODT}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ODT}]
set_property PACKAGE_PIN H20 [get_ports {DDR3_ODT}]

# PadFunction: IO_L16N_T2_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_CS_N}]
set_property SLEW FAST [get_ports {DDR3_CS_N}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_CS_N}]
set_property PACKAGE_PIN J17 [get_ports {DDR3_CS_N}]

# PadFunction: IO_L22N_T3_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[0]}]
set_property SLEW FAST [get_ports {DDR3_DM[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[0]}]
set_property PACKAGE_PIN M13 [get_ports {DDR3_DM[0]}]

# PadFunction: IO_L16P_T2_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[1]}]
set_property SLEW FAST [get_ports {DDR3_DM[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[1]}]
set_property PACKAGE_PIN K15 [get_ports {DDR3_DM[1]}]

# PadFunction: IO_L10N_T1_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[2]}]
set_property SLEW FAST [get_ports {DDR3_DM[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[2]}]
set_property PACKAGE_PIN F12 [get_ports {DDR3_DM[2]}]

# PadFunction: IO_L2N_T0_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[3]}]
set_property SLEW FAST [get_ports {DDR3_DM[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[3]}]
set_property PACKAGE_PIN A14 [get_ports {DDR3_DM[3]}]

# PadFunction: IO_L4P_T0_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[4]}]
set_property SLEW FAST [get_ports {DDR3_DM[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[4]}]
set_property PACKAGE_PIN C23 [get_ports {DDR3_DM[4]}]

# PadFunction: IO_L11P_T1_SRCC_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[5]}]
set_property SLEW FAST [get_ports {DDR3_DM[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[5]}]
set_property PACKAGE_PIN D25 [get_ports {DDR3_DM[5]}]

# PadFunction: IO_L18P_T2_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[6]}]
set_property SLEW FAST [get_ports {DDR3_DM[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[6]}]
set_property PACKAGE_PIN C31 [get_ports {DDR3_DM[6]}]

# PadFunction: IO_L24N_T3_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DM[7]}]
set_property SLEW FAST [get_ports {DDR3_DM[7]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_DM[7]}]
set_property PACKAGE_PIN F31 [get_ports {DDR3_DM[7]}]

# PadFunction: IO_L21P_T3_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[0]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[0]}]
set_property PACKAGE_PIN N16 [get_ports {DDR3_DQS_P[0]}]

# PadFunction: IO_L21N_T3_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[0]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[0]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[0]}]
set_property PACKAGE_PIN M16 [get_ports {DDR3_DQS_N[0]}]

# PadFunction: IO_L15P_T2_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[1]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[1]}]
set_property PACKAGE_PIN K12 [get_ports {DDR3_DQS_P[1]}]

# PadFunction: IO_L15N_T2_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[1]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[1]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[1]}]
set_property PACKAGE_PIN J12 [get_ports {DDR3_DQS_N[1]}]

# PadFunction: IO_L9P_T1_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[2]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[2]}]
set_property PACKAGE_PIN H16 [get_ports {DDR3_DQS_P[2]}]

# PadFunction: IO_L9N_T1_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[2]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[2]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[2]}]
set_property PACKAGE_PIN G16 [get_ports {DDR3_DQS_N[2]}]

# PadFunction: IO_L3P_T0_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[3]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[3]}]
set_property PACKAGE_PIN C15 [get_ports {DDR3_DQS_P[3]}]

# PadFunction: IO_L3N_T0_DQS_39 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[3]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[3]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[3]}]
set_property PACKAGE_PIN C14 [get_ports {DDR3_DQS_N[3]}]

# PadFunction: IO_L3P_T0_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[4]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[4]}]
set_property PACKAGE_PIN A26 [get_ports {DDR3_DQS_P[4]}]

# PadFunction: IO_L3N_T0_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[4]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[4]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[4]}]
set_property PACKAGE_PIN A27 [get_ports {DDR3_DQS_N[4]}]

# PadFunction: IO_L9P_T1_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[5]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[5]}]
set_property PACKAGE_PIN F25 [get_ports {DDR3_DQS_P[5]}]

# PadFunction: IO_L9N_T1_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[5]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[5]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[5]}]
set_property PACKAGE_PIN E25 [get_ports {DDR3_DQS_N[5]}]

# PadFunction: IO_L15P_T2_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[6]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[6]}]
set_property PACKAGE_PIN B28 [get_ports {DDR3_DQS_P[6]}]

# PadFunction: IO_L15N_T2_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[6]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[6]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[6]}]
set_property PACKAGE_PIN B29 [get_ports {DDR3_DQS_N[6]}]

# PadFunction: IO_L21P_T3_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_P[7]}]
set_property SLEW FAST [get_ports {DDR3_DQS_P[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_P[7]}]
set_property PACKAGE_PIN E27 [get_ports {DDR3_DQS_P[7]}]

# PadFunction: IO_L21N_T3_DQS_37 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_DQS_N[7]}]
set_property SLEW FAST [get_ports {DDR3_DQS_N[7]}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {DDR3_DQS_N[7]}]
set_property PACKAGE_PIN E28 [get_ports {DDR3_DQS_N[7]}]

# PadFunction: IO_L13P_T2_MRCC_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_CLK_P}]
set_property SLEW FAST [get_ports {DDR3_CLK_P}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_CLK_P}]
set_property PACKAGE_PIN H19 [get_ports {DDR3_CLK_P}]

# PadFunction: IO_L13N_T2_MRCC_38 
set_property VCCAUX_IO NORMAL [get_ports {DDR3_CLK_N}]
set_property SLEW FAST [get_ports {DDR3_CLK_N}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_CLK_N}]
set_property PACKAGE_PIN G18 [get_ports {DDR3_CLK_N}]


set_property LOC PHASER_OUT_PHY_X1Y19 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y18 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y17 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y16 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y23 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y22 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y21 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y27 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y26 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y25 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out}]
set_property LOC PHASER_OUT_PHY_X1Y24 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out}]

set_property LOC PHASER_IN_PHY_X1Y19 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y18 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y17 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y16 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y23 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y22 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
## set_property LOC PHASER_IN_PHY_X1Y21 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y27 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y26 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y25 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_in_gen.phaser_in}]
set_property LOC PHASER_IN_PHY_X1Y24 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_in_gen.phaser_in}]



set_property LOC OUT_FIFO_X1Y19 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X1Y18 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X1Y17 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X1Y16 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo}]
set_property LOC OUT_FIFO_X1Y23 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X1Y22 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X1Y21 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X1Y27 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/out_fifo}]
set_property LOC OUT_FIFO_X1Y26 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/out_fifo}]
set_property LOC OUT_FIFO_X1Y25 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/out_fifo}]
set_property LOC OUT_FIFO_X1Y24 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/out_fifo}]

set_property LOC IN_FIFO_X1Y19 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y18 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y17 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y16 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y27 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y26 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y25 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/in_fifo_gen.in_fifo}]
set_property LOC IN_FIFO_X1Y24 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/in_fifo_gen.in_fifo}]

set_property LOC PHY_CONTROL_X1Y4 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/phy_control_i}]
set_property LOC PHY_CONTROL_X1Y5 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/phy_control_i}]
set_property LOC PHY_CONTROL_X1Y6 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/phy_control_i}]

set_property LOC PHASER_REF_X1Y4 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/phaser_ref_i}]
set_property LOC PHASER_REF_X1Y5 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_1.u_ddr_phy_4lanes/phaser_ref_i}]
set_property LOC PHASER_REF_X1Y6 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/phaser_ref_i}]

set_property LOC OLOGIC_X1Y243 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y231 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y219 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y207 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_2.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y343 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y331 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y319 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/*slave_ts}]
set_property LOC OLOGIC_X1Y307 [get_cells  -hier -filter {NAME =~ */ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/*slave_ts}]

set_property LOC PLLE2_ADV_X1Y5 [get_cells -hier -filter {NAME =~ */u_ddr3_infrastructure/plle2_i}]
# [sizhuo] bluespec puts it to X0Y5 instead of X1Y5 to avoid MMCM conflicts
# but connectal does not seem to occupy X1Y5, so I put this MMCM back to X1Y5
set_property LOC MMCME2_ADV_X1Y5 [get_cells -hier -filter {NAME =~ */u_ddr3_infrastructure/gen_mmcm.mmcm_i}]


set_multicycle_path -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r_reg}] \
                    -to   [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] \
                    -setup 6

set_multicycle_path -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r_reg}] \
                    -to   [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] \
                    -hold 5

#set_multicycle_path -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r*}] \
#                    -to   [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] \
#                    -setup 6

#set_multicycle_path -from [get_cells -hier -filter {NAME =~ */mc0/mc_read_idle_r*}] \
#                    -to   [get_cells -hier -filter {NAME =~ */input_[?].iserdes_dq_.iserdesdq}] \
#                    -hold 5

set_false_path -through [get_pins -filter {NAME =~ */DQSFOUND} -of [get_cells -hier -filter {REF_NAME == PHASER_IN_PHY}]]

set_multicycle_path -through [get_pins -filter {NAME =~ */OSERDESRST} -of [get_cells -hier -filter {REF_NAME == PHASER_OUT_PHY}]] -setup 2 -start
set_multicycle_path -through [get_pins -filter {NAME =~ */OSERDESRST} -of [get_cells -hier -filter {REF_NAME == PHASER_OUT_PHY}]] -hold 1 -start

set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/device_temp_sync_r1*}] 20
set_max_delay -from [get_cells -hier *rstdiv0_sync_r1_reg*] -to [get_pins -filter {NAME =~ */RESET} -of [get_cells -hier -filter {REF_NAME == PHY_CONTROL}]] -datapath_only 5
#set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/device_temp_sync_r1*}] 20
#set_max_delay -from [get_cells -hier rstdiv0_sync_r1*] -to [get_pins -filter {NAME =~ */RESET} -of [get_cells -hier -filter {REF_NAME == PHY_CONTROL}]] -datapath_only 5
          
set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1_reg*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/xadc_supplied_temperature.rst_r1*}] 20
#set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *ddr3_infrastructure/rstdiv0_sync_r1*}] -to [get_cells -hier -filter {NAME =~ *temp_mon_enabled.u_tempmon/*rst_r1*}] 20

######################################################################################################
# AREA GROUPS
######################################################################################################
#startgroup
#create_pblock pblock_ddr3
#resize_pblock pblock_ddr3 -add { SLICE_X146Y201:SLICE_X205Y348 DSP48_X13Y82:DSP48_X19Y137 RAMB18_X9Y82:RAMB18_X13Y137 RAMB36_X9Y41:RAMB36_X13Y68 }
#add_cells_to_pblock pblock_ddr3 [get_cells [list ddr3* ]]
#endgroup


######################################################################################################
# TIMING CONSTRAINTS
######################################################################################################
# ddr3 sys clk
create_clock -name ddr3_sys_clk -period 5 [get_pins host_pcieHostTop_sys_clk_200mhz/O]

# there are paths from portal clk to ddr3 sys clk, should be async...
set portal_clk [get_clocks -of_objects [get_pins host_pcieHostTop_ep7/clkgen_pll/CLKOUT1]]
set_clock_groups -asynchronous -group ddr3_sys_clk -group $portal_clk

