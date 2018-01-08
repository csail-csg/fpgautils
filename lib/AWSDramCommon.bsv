
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

import Axi4MasterSlave::*;
import AxiBits::*;

import DramCommon::*;

// AWS physical (axi) interface
typedef 64 AWSDramAxiAddrSz;
typedef 16 AWSDramAxiIdSz;
typedef 512 AWSDramAxiDataSz;
typedef TDiv#(AWSDramAxiDataSz, 8) AWSDramAxiBESz;
typedef Bit#(AWSDramAxiAddrSz) AWSDramAxiAddr;
typedef Bit#(AWSDramAxiIdSz) AWSDramAxiId;
typedef Bit#(AWSDramAxiDataSz) AWSDramAxiData;
typedef Bit#(AWSDramAxiBESz) AWSDramAxiBE;

interface AWSDramPins;
    (* always_enabled, always_ready, prefix = "" *)
    interface Axi4MasterBits#(
        AWSDramAxiAddrSz,
        AWSDramAxiDataSz,
        AWSDramAxiIdSz,
        Empty
    ) axiMaster;
endinterface

// AWS user interface: 16GB DRAM, access with 64B aligned
typedef Bit#(0) AWSDramErr; // no specific error

typedef DramUser#(
    maxReadNum,
    maxWriteNum,
    simDelay,
    AWSDramErr
) AWSDramUser#(
    numeric type maxReadNum,
    numeric type maxWriteNum,
    numeric type simDelay
);

// AWS full interface
typedef DramFull#(
    maxReadNum,
    maxWriteNum,
    simDelay,
    AWSDramErr,
`ifdef BSIM
    Empty
`else
    AWSDramPins
`endif
) AWSDramFull#(
    numeric type maxReadNum,
    numeric type maxWriteNum,
    numeric type simDelay
);
