
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

import Vector::*;
import Ehr::*;

// An addr buffer keeps all the issued req addr in order. We can either insert
// a new address into it, or search for a specific address. Address is dequeued
// in order form the buffer.

interface AddrBuffer#(numeric type buffSz, numeric type addrSz);
    // search mathching addr
    method Bool searchHit(Bit#(addrSz) addr);
    // enq in order
    method Action enq(Bit#(addrSz) addr);
    // deq oldest addr
    method Action deq;
endinterface

// in order addr buffer: searchHit < enq < deq
module mkAddrBuffer(AddrBuffer#(buffSz, addrSz)) provisos(
    Add#(1, a__, buffSz),
    Alias#(elemCntT, Bit#(TLog#(TAdd#(buffSz, 1))))
);
    // youngest addr is always in addrVec[0]
    Vector#(buffSz, Reg#(Bit#(addrSz))) addrVec <- replicateM(mkRegU);

    // number of valid req
    Ehr#(2, elemCntT) cnt <- mkEhr(0);
    Integer cnt_search_port = 0;
    Integer cnt_enq_port = 0;
    Integer cnt_deq_port = 1;

    // not full (for enq)
    Bool isNotFull = cnt[cnt_enq_port] < fromInteger(valueof(buffSz));

    // not empty (for deq), lazy guard
    Wire#(Bool) isNotEmpty <- mkBypassWire;
    (* fire_when_enabled, no_implicit_conditions *)
    rule setNotEmpty;
        isNotEmpty <= cnt[0] > 0;
    endrule

    method Bool searchHit(Bit#(addrSz) addr);
        elemCntT cur_cnt = cnt[cnt_search_port];
        function Bool hit(Integer i);
            return fromInteger(i) < cur_cnt && addrVec[i] == addr;
        endfunction
        Vector#(buffSz, Integer) vec = genVector;
        return any(hit, vec);
    endmethod

    method Action enq(Bit#(addrSz) addr) if(isNotFull);
        // insert new req into position 0, and shift older req backwards
        for(Integer i = 1; i < valueOf(buffSz); i = i+1) begin
            addrVec[i] <= addrVec[i - 1];
        end
        addrVec[0] <= addr;
        // incr buffer cnt
        cnt[cnt_enq_port] <= cnt[cnt_enq_port] + 1;
    endmethod

    method Action deq if(isNotEmpty);
        // decr buffer cnt
        cnt[cnt_deq_port] <= cnt[cnt_deq_port] - 1;
    endmethod
endmodule
