
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
import GetPut::*;
import RegFile::*;
import FIFO::*;

import AxiBits::*;
import Axi4MasterSlave::*;

import DramCommon::*;

// Simulated DRAM with axi interface. Currently only support burst len = 1

interface SimAxi4Dram#(
    // axi ifc sizes
    numeric type axiAddrSz,
    numeric type axiDataSz,
    numeric type axiIdSz,
    // DRAM size in terms of axi data
    numeric type lgDramSzAxiData,
    // simulated resp delay (fullly pipelined)
    numeric type delay
);
    interface Axi4Slave#(axiAddrSz, axiDataSz, axiIdSz) slave;
endinterface

module mkSimAxi4Dram(SimAxi4Dram#(
    axiAddrSz, axiDataSz, axiIdSz, lgDramSzAxiData, delay)
) provisos(
    Add#(1, a__, delay),
    Add#(lgDramSzAxiData, b__, axiAddrSz),
    Alias#(rdReqT, Axi4ReadRequest#(axiAddrSz, axiIdSz)),
    Alias#(rdRespT, Axi4ReadResponse#(axiDataSz, axiIdSz)),
    Alias#(wrReqT, Axi4WriteRequest#(axiAddrSz, axiIdSz)),
    Alias#(wrDataT, Axi4WriteData#(axiDataSz, axiIdSz)),
    Alias#(wrRespT, Axi4WriteResponse#(axiIdSz)),
    NumAlias#(axiBESz, TDiv#(axiDataSz, 8)),
    Bits#(Vector#(axiBESz, Bit#(8)), axiDataSz)
);
    RegFile#(Bit#(lgDramSzAxiData), Bit#(axiDataSz)) mem <- mkRegFileFull;

    FIFO#(rdReqT) rdReqQ <- mkFIFO;
    Vector#(delay, FIFO#(rdRespT)) rdRespQ <- replicateM(mkFIFO);

    FIFO#(wrReqT) wrReqQ <- mkFIFO;
    FIFO#(wrDataT) wrDataQ <- mkFIFO;
    Vector#(delay, FIFO#(wrRespT)) wrRespQ <- replicateM(mkFIFO);

    function Bit#(lgDramSzAxiData) getMemIndex(Bit#(axiAddrSz) addr);
        return truncate(addr >> valueof(TLog#(axiBESz)));
    endfunction

    rule doReadReq;
        rdReqQ.deq;
        rdReqT req = rdReqQ.first;
        doAssert(req.len == 0, "read req can only have 1 transfer");
        rdRespQ[0].enq(Axi4ReadResponse {
            data: mem.sub(getMemIndex(req.address)),
            resp: 0,
            last: 1,
            id: req.id
        });
    endrule

    rule doWriteReq;
        wrReqQ.deq;
        wrDataQ.deq;
        wrReqT req = wrReqQ.first;
        wrDataT data = wrDataQ.first;
        doAssert(req.len == 0, "write req can only have 1 transfer");
        doAssert(data.last == 1, "only 1 write data transfer");
        doAssert(data.byteEnable != 0, "must have some bytes to write");
        // update mem
        let idx = getMemIndex(req.address);
        Vector#(axiBESz, Bit#(8)) wrData = unpack(data.data);
        Vector#(axiBESz, Bit#(8)) newData = unpack(mem.sub(idx));
        for(Integer i = 0; i < valueOf(axiBESz); i = i+1) begin
            if(data.byteEnable[i] == 1) begin
                newData[i] = wrData[i];
            end
        end
        mem.upd(idx, pack(newData));
        // send resp
        wrRespQ[0].enq(Axi4WriteResponse {
            resp: 0,
            id: req.id
        });
    endrule

    for(Integer i = 0; i < valueof(delay) - 1; i = i+1) begin
        rule delayReadResp;
            rdRespQ[i].deq;
            rdRespQ[i + 1].enq(rdRespQ[i].first);
        endrule
        rule dleayWriteResp;
            wrRespQ[i].deq;
            wrRespQ[i + 1].enq(wrRespQ[i].first);
        endrule
    end

    interface Axi4Slave slave;
        interface Put req_ar = toPut(rdReqQ);
        interface Get resp_read = toGet(rdRespQ[valueof(delay) - 1]);
        interface Put req_aw = toPut(wrReqQ);
        interface Put resp_write = toPut(wrDataQ);
        interface Get resp_b = toGet(wrRespQ[valueof(delay) - 1]);
    endinterface
endmodule
