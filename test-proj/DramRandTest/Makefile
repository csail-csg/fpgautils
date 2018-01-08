
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
LOG_MAX_ADDR_NUM ?= 10
LOG_STALL_RATIO ?= 7

# DRAM type to test VC707 or AWSF1
DRAM_TYPE ?=

PROJ_DIR = $(CURDIR)
EHR_DIR = $(PROJ_DIR)/../../../procs/lib
FPGA_LIB_DIR = $(PROJ_DIR)/../../lib
XILINX_IP_DIR = $(PROJ_DIR)/../../xilinx
CORE_SCRIPT_DIR = $(PROJ_DIR)/../../core-scripts

BUILD_DIR = $(PROJ_DIR)/build
ifeq ($(DRAM_TYPE),)
PROJECTDIR = $(BUILD_DIR)/$(BOARD)
else
PROJECTDIR = $(BUILD_DIR)/$(BOARD).$(DRAM_TYPE)
endif

S2H_INTERFACES = DRTestRequest:DRTestWrapper.request
H2S_INTERFACES = DRTestWrapper:DRTestIndication:host

BSVFILES = $(PROJ_DIR)/bsv/DRTestIF.bsv 

CPPFILES = $(PROJ_DIR)/cpp/main.cpp

CONNECTALFLAGS += -D IMPORT_HOSTIF -D XILINX_SYS_CLK --nocache -v \
				  -D LOG_MAX_ADDR_NUM=$(LOG_MAX_ADDR_NUM) \
				  --bsvpath $(PROJ_DIR)/bsv \
				  --bsvpath $(EHR_DIR) \
				  --bsvpath $(FPGA_LIB_DIR) \
				  --verilog $(XILINX_IP_DIR)/reset_regs \
				  --cflags " -std=c++0x " \
				  --cflags " -D LOG_MAX_ADDR_NUM=$(LOG_MAX_ADDR_NUM) " \
				  --cflags " -D LOG_STALL_RATIO=$(LOG_STALL_RATIO) " \
				  --bscflags " -D USER_CLK_PERIOD=$(USER_CLK_PERIOD) " \
				  --bscflags " -D LOG_MAX_ADDR_NUM=$(LOG_MAX_ADDR_NUM) " \
				  --bscflags " -D LOG_STALL_RATIO=$(LOG_STALL_RATIO) " \
				  --bscflags " -D USE_XILINX_SYNC_FIFO "

ifneq (,$(filter $(BOARD),vc707 awsf1))
# synthesize for vc707 or awsf1

AUTOTOP = --interface pins:DRTestWrapper.pins

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
CONNECTALFLAGS += --bscflags " -D TEST_VC707 " \
				  --verilog $(XILINX_IP_DIR)/vc707/ddr3_1GB_bluespec/ \
				  -C $(XILINX_IP_DIR)/vc707/constraints/ddr3_1GB_bluespec.xdc
else
PIN_TYPE = AWSDramPins
PIN_TYPE_INCLUDE = AWSDramCommon
CONNECTALFLAGS += -D AWSF1_DDR_A
CONNECTALFLAGS += --bscflags " -D TEST_AWSF1 "
endif

else
# bsim simulation

CONNECTALFLAGS += --cflags " -D BSIM " \
				  --bscflags " -D BSIM " \
				  --bscflags " -D TEST_$(DRAM_TYPE) "

endif 

include $(CONNECTALDIR)/Makefile.connectal

