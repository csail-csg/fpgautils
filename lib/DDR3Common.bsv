
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

// 1GB DDR3 types and interfaces

// physical interface
typedef 14 DDR3PhyRowWidth;
typedef 3 DDR3PhyBankWidth;

(* always_enabled, always_ready *)
interface DDR3_1GB_Pins;
    // XXX pin names appear in XDC, don't change!
    (* prefix = "", result = "CLK_P" *)
    method    Bit#(1)                clk_p;
    (* prefix = "", result = "CLK_N" *)
    method    Bit#(1)                clk_n;
    (* prefix = "", result = "A" *)
    method    Bit#(DDR3PhyRowWidth)  a;
    (* prefix = "", result = "BA" *)
    method    Bit#(DDR3PhyBankWidth) ba;
    (* prefix = "", result = "RAS_N" *)
    method    Bit#(1)                ras_n;
    (* prefix = "", result = "CAS_N" *)
    method    Bit#(1)                cas_n;
    (* prefix = "", result = "WE_N" *)
    method    Bit#(1)                we_n;
    (* prefix = "", result = "RESET_N" *)
    method    Bit#(1)                reset_n;
    (* prefix = "", result = "CS_N" *)
    method    Bit#(1)                cs_n;
    (* prefix = "", result = "ODT" *)
    method    Bit#(1)                odt;
    (* prefix = "", result = "CKE" *)
    method    Bit#(1)                cke;
    (* prefix = "", result = "DM" *)
    method    Bit#(8)                dm;
    (* prefix = "DQ" *)
    interface Inout#(Bit#(64))       dq;
    (* prefix = "DQS_P" *)
    interface Inout#(Bit#(8))        dqs_p;
    (* prefix = "DQS_N" *)
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
typedef 512 DDR3UserDataSz;
typedef TDiv#(DDR3UserDataSz, 8) DDR3UserBESz;
typedef 24 DDR3UserAddrSz; // in terms of 64B

typedef Bit#(DDR3UserDataSz) DDR3UserData;
typedef Bit#(DDR3UserBESz) DDR3UserBE;
typedef Bit#(DDR3UserAddrSz) DDR3UserAddr;

typedef struct { // user read/write req
    DDR3UserAddr addr;
    DDR3UserData data;
    DDR3UserBE wrBE; // all 0 means read, otherwise wrBE[i]=1 means to write byte i
} DDR3UserReq deriving(Bits, Eq, FShow);

typedef enum {
    DropResp,
    ReadCntOverflow,
    ReadCntUnderflow
} DDR3Err deriving(Bits, Eq, FShow);

interface DDR3_1GB_User#(
    numeric type maxReadNum, // maximum in-flight read cnt
    numeric type simDelay // only matters in simulation
);
    //method Bool initDone;
    method Action req(DDR3UserReq r);
    method ActionValue#(DDR3UserData) rdResp; // only read has resp
    method ActionValue#(DDR3Err) err;
endinterface

interface DDR3_1GB_Controller#(
    numeric type maxReadNum, // maximum in-flight read cnt
    numeric type simDelay // only matters in simulation
);
`ifndef BSIM
    interface DDR3_1GB_Pins ddr3;
`endif
    interface DDR3_1GB_User#(maxReadNum, simDelay) user;
endinterface

typedef struct {
    Integer syncFifoSz; // depth of sync fifos
    Bool useBramSyncFifo; // use bram fifo for sync fifos
    Bool useBramRespBuffer; // use bram fifo to buffer read resp to do flow ctrl (depth = maxReadNum * 2)
} DDR3_Controller_Config deriving(Bits, Eq);

instance DefaultValue#(DDR3_Controller_Config);
    defaultValue = DDR3_Controller_Config {
        syncFifoSz: 8, // 8 elements could provide enough BW according to SyncTest
        useBramSyncFifo: False,
        useBramRespBuffer: True // use BRAM should allows us to have large maxReadNum
    };
endinstance
