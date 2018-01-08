
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

import BRAM::*;
import DramCommon::*;
import DRTestIF::*;
import DefaultValue::*;

interface AddrBram;
    method Action req(Bool isWr, TestAddrIdx idx, DramUserAddr a);
    method ActionValue#(DramUserAddr) resp; // only for read
endinterface

(* synthesize *)
module mkAddrBram(AddrBram);
    BRAM1Port#(TestAddrIdx, DramUserAddr) bram <- mkBRAM1Server(defaultValue);

    method Action req(Bool isWr, TestAddrIdx idx, DramUserAddr a);
        bram.portA.request.put(BRAMRequest {
            write: isWr,
            responseOnWrite: False,
            address: idx,
            datain: a
        });
    endmethod

    method ActionValue#(DramUserAddr) resp;
        let r <- bram.portA.response.get;
        return r;
    endmethod
endmodule

interface DataBram;
    method Action req(TestAddrIdx idx, DramUserBE wrBE, DramUserData data);
    method ActionValue#(DramUserData) resp; // only for read
endinterface

(* synthesize *)
module mkDataBram(DataBram);
    BRAM1PortBE#(TestAddrIdx, DramUserData, DramUserBESz) bram <- mkBRAM1ServerBE(defaultValue);

    method Action req(TestAddrIdx idx, DramUserBE wrBE, DramUserData data);
        bram.portA.request.put(BRAMRequestBE {
            writeen: wrBE,
            responseOnWrite: False,
            address: idx,
            datain: data
        });
    endmethod

    method ActionValue#(DramUserData) resp;
        let r <- bram.portA.response.get;
        return r;
    endmethod
endmodule
