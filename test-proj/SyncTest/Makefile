
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

LOG_MAX_FIFO_SZ ?= 10
USER_CLK_PERIOD = 40

PROJ_DIR = $(CURDIR)
XILINX_IP_DIR = $(PROJ_DIR)/../../xilinx
SYNC_LIB_DIR = $(PROJ_DIR)/../../lib
CORE_SCRIPT_DIR = $(PROJ_DIR)/../../core-scripts

BUILD_DIR = $(PROJ_DIR)/build/user_$(USER_CLK_PERIOD)ns
PROJECTDIR = $(BUILD_DIR)/$(BOARD)

S2H_INTERFACES = SyncTestRequest:SyncTestWrapper.request
H2S_INTERFACES = SyncTestWrapper:SyncTestIndication:host

BSVFILES = $(PROJ_DIR)/bsv/SyncTestIF.bsv 

CPPFILES = $(PROJ_DIR)/cpp/main.cpp 

CONNECTALFLAGS += -D IMPORT_HOSTIF --nocache -v \
				  --bsvpath $(PROJ_DIR)/bsv --bsvpath $(SYNC_LIB_DIR) \
				  --verilog $(XILINX_IP_DIR)/reset_regs \
				  --bscflags " -D USER_CLK_PERIOD=$(USER_CLK_PERIOD) " \
				  --bscflags " -D LOG_MAX_FIFO_SZ=$(LOG_MAX_FIFO_SZ) " \
				  --cflags " -std=c++0x " \
				  --cflags " -DUSER_CLK_PERIOD=$(USER_CLK_PERIOD) " \
				  --cflags " -DLOG_MAX_FIFO_SZ=$(LOG_MAX_FIFO_SZ) "

# Use Xilinx Sync FIFO
CONNECTALFLAGS += --bscflags " -D USE_XILINX_SYNC_FIFO "
#CONNECTALFLAGS += --bscflags " -D USE_BSV_BRAM_SYNC_FIFO "
#CONNECTALFLAGS += --bscflags " -D USE_CONNECTAL_BRAM_SYNC_FIFO "

ifeq ($(BOARD),$(filter $(BOARD),vc707 awsf1))
# synthesize for VC707 or AWS F1

SYNC_FIFO_XCI = $(CONNECTALDIR)/out/$(BOARD)/sync_fifo_w32_d16/sync_fifo_w32_d16.xci
SYNC_BRAM_FIFO_XCI = $(CONNECTALDIR)/out/$(BOARD)/sync_bram_fifo_w36_d512/sync_bram_fifo_w36_d512.xci

CONNECTALFLAGS += --xci $(SYNC_FIFO_XCI) \
				  --xci $(SYNC_BRAM_FIFO_XCI)

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

else
# simulation

CONNECTALFLAGS += --bscflags " -D BSIM " \
				  --cflags " -D BSIM "

endif

include $(CONNECTALDIR)/Makefile.connectal

clean.%:
	rm -rf $(BUILD_DIR)/$*

