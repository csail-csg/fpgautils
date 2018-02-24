
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

USER_CLK_PERIOD = 20

PROJ_DIR = $(CURDIR)
FPGA_LIB_DIR = $(PROJ_DIR)/../../lib
XILINX_IP_DIR = $(PROJ_DIR)/../../xilinx
CORE_SCRIPT_DIR = $(PROJ_DIR)/../../core-scripts

BUILD_DIR = $(PROJ_DIR)/build
PROJECTDIR = $(BUILD_DIR)/$(BOARD)

S2H_INTERFACES = MulDivTestRequest:MulDivTestWrapper.request
H2S_INTERFACES = MulDivTestWrapper:MulDivTestIndication

BSVFILES = $(PROJ_DIR)/bsv/MulDivTestIF.bsv 

CPPFILES = $(PROJ_DIR)/cpp/main.cpp 

CONNECTALFLAGS += --nocache -v \
				  --bsvpath $(PROJ_DIR)/bsv \
				  --bsvpath $(FPGA_LIB_DIR) \
				  --verilog $(XILINX_IP_DIR)/reset_regs \
				  --verilog $(XILINX_IP_DIR)/fpu \
				  --cflags " -std=c++0x " \
				  --bscflags " -check-assert " \
				  --bscflags " -D USER_CLK_PERIOD=$(USER_CLK_PERIOD) " \
				  --bscflags " -D USE_XILINX_SYNC_FIFO "

# test specific params
CONNECTALFLAGS += -D USER_TAG_SIZE=4 \
				  -D MAX_TEST_NUM=1024 \
				  -D LOG_DELAY_CYCLES=7

# xilinx multiplier latency
XILINX_INT_MUL_LATENCY = 3
CONNECTALFLAGS += --bscflags " -D XILINX_INT_MUL_LATENCY=$(XILINX_INT_MUL_LATENCY) "

ifeq ($(BOARD),$(filter $(BOARD),vc707 awsf1))
# synthesize for VC707 or AWSF1

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

# int mul/div
INT_MUL_SIGNED_XCI = $(CONNECTALDIR)/out/$(BOARD)/int_mul_signed/int_mul_signed.xci
INT_MUL_UNSIGNED_XCI = $(CONNECTALDIR)/out/$(BOARD)/int_mul_unsigned/int_mul_unsigned.xci
INT_MUL_SIGNED_UNSIGNED_XCI = $(CONNECTALDIR)/out/$(BOARD)/int_mul_signed_unsigned/int_mul_signed_unsigned.xci
INT_DIV_UNSIGNED_XCI = $(CONNECTALDIR)/out/$(BOARD)/int_div_unsigned/int_div_unsigned.xci

# also configure the latency of IP core
INT_MUL_LATENCY = $(XILINX_INT_MUL_LATENCY)
INT_DIV_LATENCY = 12

CONNECTALFLAGS += --xci $(INT_MUL_SIGNED_XCI) \
				  --xci $(INT_MUL_UNSIGNED_XCI) \
				  --xci $(INT_MUL_SIGNED_UNSIGNED_XCI) \
				  --xci $(INT_DIV_UNSIGNED_XCI)

prebuild:: $(INT_MUL_SIGNED_XCI) $(INT_DIV_UNSIGNED_XCI)

$(INT_MUL_SIGNED_XCI): $(CORE_SCRIPT_DIR)/synth_int_mul.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^ -tclargs $(INT_MUL_LATENCY))

$(INT_DIV_UNSIGNED_XCI): $(CORE_SCRIPT_DIR)/synth_int_div.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^ -tclargs $(INT_DIV_LATENCY))

# Force to generate IP core, because we pass args to synth tcl
.PHONY: $(INT_MUL_SIGNED_XCI) $(INT_DIV_UNSIGNED_XCI)

# AWS needs to know int mul div are used
ifeq ($(BOARD),awsf1)
CONNECTALFLAGS += -D AWSF1_INT_MULDIV
endif


else
# simulation

CONNECTALFLAGS += --bscflags " -D BSIM " \
				  --cflags " -D BSIM "

endif


include $(CONNECTALDIR)/Makefile.connectal

clean.%:
	rm -rf $(BUILD_DIR)/$*

