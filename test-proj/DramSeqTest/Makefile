
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

CONNECTALDIR = $(RISCY_HOME)/connectal

USER_CLK_PERIOD ?= 40
# DRAM type to test VC707 or AWSF1
DRAM_TYPE ?= VC707
ifeq ($(BOARD),vc707)
DRAM_TYPE = VC707
endif
ifeq ($(BOARD),awsf1)
DRAM_TYPE = AWSF1
endif

PROJ_DIR = $(CURDIR)
FPGA_LIB_DIR = $(PROJ_DIR)/../../lib
XILINX_IP_DIR = $(PROJ_DIR)/../../xilinx
CORE_SCRIPT_DIR = $(PROJ_DIR)/../../core-scripts

BUILD_DIR = $(PROJ_DIR)/build
PROJECTDIR = $(BUILD_DIR)/$(BOARD).$(DRAM_TYPE)

S2H_INTERFACES = DSTestRequest:DSTestWrapper.request
H2S_INTERFACES = DSTestWrapper:DSTestIndication:host

BSVFILES = $(PROJ_DIR)/bsv/DSTestIF.bsv 

CPPFILES = $(PROJ_DIR)/cpp/main.cpp 

CONNECTALFLAGS += -D IMPORT_HOSTIF -D XILINX_SYS_CLK --nocache -v \
				  --bsvpath $(PROJ_DIR)/bsv --bsvpath $(FPGA_LIB_DIR) \
				  --verilog $(XILINX_IP_DIR)/reset_regs \
				  --cflags " -std=c++0x " \
				  --cflags " -D USER_CLK_PERIOD=$(USER_CLK_PERIOD) " \
				  --bscflags " -check-assert " \
				  --bscflags " -D USER_CLK_PERIOD=$(USER_CLK_PERIOD) " \
				  --bscflags " -D USE_XILINX_SYNC_FIFO "\
				  --bscflags " -D TEST_$(DRAM_TYPE) "

ifeq ($(BOARD),$(filter $(BOARD),vc707 awsf1))
# synthesize for VC707 or AWSF1

AUTOTOP = --interface pins:DSTestWrapper.pins

# sync FIFOs
SYNC_FIFO_XCI = $(CONNECTALDIR)/out/$(BOARD)/sync_fifo_w32_d16/sync_fifo_w32_d16.xci
SYNC_BRAM_FIFO_XCI = $(CONNECTALDIR)/out/$(BOARD)/sync_bram_fifo_w36_d512/sync_bram_fifo_w36_d512.xci

CONNECTALFLAGS += --xci $(SYNC_FIFO_XCI) --xci $(SYNC_BRAM_FIFO_XCI)

prebuild:: $(SYNC_FIFO_XCI) $(SYNC_BRAM_FIFO_XCI)

$(SYNC_FIFO_XCI): $(CORE_SCRIPT_DIR)/synth_sync_fifo.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^)

$(SYNC_BRAM_FIFO_XCI): $(CORE_SCRIPT_DIR)/synth_sync_bram_fifo.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^)

# AWS needs to know sync fifo is used
ifeq ($(BOARD),awsf1)
CONNECTALFLAGS += -D AWSF1_SYNC_FIFO
endif

# VC707 needs some more clocking constraints
ifeq ($(BOARD),vc707)
CONNECTALFLAGS += -C $(XILINX_IP_DIR)/vc707/constraints/clocks.xdc
endif

# DRAM
ifeq ($(BOARD),vc707)
PIN_TYPE = DDR3_1GB_Pins
PIN_TYPE_INCLUDE = DDR3Common
CONNECTALFLAGS += --verilog $(XILINX_IP_DIR)/vc707/ddr3_1GB_bluespec/ \
				  -C $(XILINX_IP_DIR)/vc707/constraints/ddr3_1GB_bluespec.xdc 
else
PINTYPE = AWSDramPins
PIN_TYPE_INCLUDE = AWSDramCommon
endif

else
# simulation

CONNECTALFLAGS += --bscflags " -D BSIM " \
				  --cflags " -D BSIM "

endif


include $(CONNECTALDIR)/Makefile.connectal

clean.%:
	rm -rf $(BUILD_DIR)/$*

