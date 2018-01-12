
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
#EHR_DIR = $(PROJ_DIR)/../../../procs/lib
FPGA_LIB_DIR = $(PROJ_DIR)/../../lib
XILINX_IP_DIR = $(PROJ_DIR)/../../xilinx
CORE_SCRIPT_DIR = $(PROJ_DIR)/../../core-scripts

BUILD_DIR = $(PROJ_DIR)/build
PROJECTDIR = $(BUILD_DIR)/$(BOARD)

S2H_INTERFACES = FpuTestRequest:FpuTestWrapper.request
H2S_INTERFACES = FpuTestWrapper:FpuTestIndication

BSVFILES = $(PROJ_DIR)/bsv/FpuTestIF.bsv 

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

# FPU
FP_FMA_XCI = $(CONNECTALDIR)/out/$(BOARD)/fp_fma/fp_fma.xci
FP_DIV_XCI = $(CONNECTALDIR)/out/$(BOARD)/fp_div/fp_div.xci
FP_SQRT_XCI = $(CONNECTALDIR)/out/$(BOARD)/fp_sqrt/fp_sqrt.xci
# also configure the latency and rate (number of cycles per input) of IP core
FP_FMA_LATENCY = 4
FP_DIV_LATENCY = 12
FP_DIV_RATE = 1
FP_SQRT_LATENCY = 8
FP_SQRT_RATE = 1

CONNECTALFLAGS += --xci $(FP_FMA_XCI) --xci $(FP_DIV_XCI) --xci $(FP_SQRT_XCI)

prebuild:: $(FP_FMA_XCI) $(FP_DIV_XCI) $(FP_SQRT_XCI)

$(FP_FMA_XCI): $(CORE_SCRIPT_DIR)/synth_fp_fma.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^ -tclargs $(FP_FMA_LATENCY))

$(FP_DIV_XCI): $(CORE_SCRIPT_DIR)/synth_fp_div.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^ -tclargs $(FP_DIV_LATENCY) $(FP_DIV_RATE))

$(FP_SQRT_XCI): $(CORE_SCRIPT_DIR)/synth_fp_sqrt.tcl
	(cd $(PROJECTDIR); vivado -mode batch -source $^ -tclargs $(FP_SQRT_LATENCY) $(FP_SQRT_RATE))

# Force to generate IP core, because we pass args to synth tcl
.PHONY: $(FP_FMA_XCI) $(FP_DIV_XCI) $(FP_SQRT_XCI)

# AWS needs to know xilinx FPU is used
ifeq ($(BOARD),awsf1)
CONNECTALFLAGS += -D AWSF1_FPU
endif

else
# simulation

CONNECTALFLAGS += --bscflags " -D BSIM " \
				  --cflags " -D BSIM "

endif


include $(CONNECTALDIR)/Makefile.connectal

clean.%:
	rm -rf $(BUILD_DIR)/$*

