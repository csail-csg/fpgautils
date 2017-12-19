
// Copyright (c) 2017 Massachusetts Institute of Technology
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Clocks::*;
import FShow::*;
import ClientServer::*;
import DefaultValue::*;

import DramCommon::*;

// VC707 1GB DDR3

// physical interface
typedef 14 DDR3PhyRowWidth;
typedef 3 DDR3PhyBankWidth;

(* always_enabled, always_ready *)
interface DDR3_1GB_Pins;
    // XXX pin names appear in XDC, don't change!
    (* prefix = "", result = "DDR3_CLK_P" *)
    method    Bit#(1)                clk_p;
    (* prefix = "", result = "DDR3_CLK_N" *)
    method    Bit#(1)                clk_n;
    (* prefix = "", result = "DDR3_A" *)
    method    Bit#(DDR3PhyRowWidth)  a;
    (* prefix = "", result = "DDR3_BA" *)
    method    Bit#(DDR3PhyBankWidth) ba;
    (* prefix = "", result = "DDR3_RAS_N" *)
    method    Bit#(1)                ras_n;
    (* prefix = "", result = "DDR3_CAS_N" *)
    method    Bit#(1)                cas_n;
    (* prefix = "", result = "DDR3_WE_N" *)
    method    Bit#(1)                we_n;
    (* prefix = "", result = "DDR3_RESET_N" *)
    method    Bit#(1)                reset_n;
    (* prefix = "", result = "DDR3_CS_N" *)
    method    Bit#(1)                cs_n;
    (* prefix = "", result = "DDR3_ODT" *)
    method    Bit#(1)                odt;
    (* prefix = "", result = "DDR3_CKE" *)
    method    Bit#(1)                cke;
    (* prefix = "", result = "DDR3_DM" *)
    method    Bit#(8)                dm;
    (* prefix = "DDR3_DQ" *)
    interface Inout#(Bit#(64))       dq;
    (* prefix = "DDR3_DQS_P" *)
    interface Inout#(Bit#(8))        dqs_p;
    (* prefix = "DDR3_DQS_N" *)
    interface Inout#(Bit#(8))        dqs_n;
endinterface

// app interface of xilinx IP core (for BVI)
// use Bluespec 400MHz DDR3 IP
typedef 256 DDR3AppDataSz;
typedef TDiv#(DDR3AppDataSz, 8) DDR3AppBESz;
typedef 27 DDR3AppAddrSz; // in terms of 8B

typedef Bit#(DDR3AppDataSz) DDR3AppData;
typedef Bit#(DDR3AppBESz) DDR3AppBE;
typedef Bit#(DDR3AppAddrSz) DDR3AppAddr;

interface DDR3_1GB_App;
    interface Clock       clock;
    interface Reset       reset;
    method    Bool        init_done;
    method    Action      app_addr(DDR3AppAddr i);
    method    Action      app_cmd(Bit#(3) i);
    method    Action      app_en(Bool i);
    method    Action      app_wdf_data(DDR3AppData i);
    method    Action      app_wdf_end(Bool i);
    method    Action      app_wdf_mask(DDR3AppBE i);
    method    Action      app_wdf_wren(Bool i);
    method    DDR3AppData app_rd_data;
    method    Bool        app_rd_data_end;
    method    Bool        app_rd_data_valid;
    method    Bool        app_rdy;
    method    Bool        app_wdf_rdy;   
endinterface

interface DDR3_1GB_Xilinx;
    interface DDR3_1GB_Pins ddr3;
    interface DDR3_1GB_App app;
endinterface

// User interface
typedef enum {
    DropResp,
    ReadCntOverflow,
    ReadCntUnderflow
} DDR3Err deriving(Bits, Eq, FShow);

typedef DramUser#(
    maxReadNum, 0, simDelay, DDR3Err
) DDR3_1GB_User#(numeric type maxReadNum, numeric type simDelay);

// Full controller
typedef DramFull#(
    maxReadNum, 0, simDelay, DDR3Err,
`ifdef BSIM
    Empty
`else
    DDR3_1GB_Pins
`endif
) DDR3_1GB_Full#(numeric type maxReadNum, numeric type simDelay);

