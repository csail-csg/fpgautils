
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

import GetPut::*;
import BRAMFIFO::*;
import FIFO::*;
import Clocks::*;

import Axi4MasterSlave::*;
import AxiBits::*;

import DramCommon::*;
import AWSDramCommon::*;
import WriteBuffer::*;
import AddrBuffer::*;
import Axi4MasterBitsSync::*;
import SimAxiDram::*;

export mkAWSDramController;
export mkAWSDramBlockController;

`ifdef BSIM
typedef 24 AWSDramMaxUserAddrSz; // simulation: 1GB
`else
typedef 28 AWSDramMaxUserAddrSz; // F1 FPGA: 16GB
`endif

// when translate to AXI byte address, we chop off overflowed MSBs. Overflow
// may not be an error because of wrong path loads
function AWSDramAxiAddr toAWSDramAxiAddr(DramUserAddr a);
    Bit#(AWSDramMaxUserAddrSz) addr = truncate(a);
    return zeroExtend({addr, 6'b0});
endfunction

module mkAWSDramController#(
    Clock dramAxiClk, Reset dramAxiRst
)(
    AWSDramFull#(maxReadNum, maxWriteNum, simDelay)
) provisos(
    Add#(1, a__, maxReadNum),
    Add#(1, b__, maxWriteNum),
    Add#(1, c__, simDelay)
);
    // a shallow FIFO to buffer req; we assume stallings by partial forwarding
    // in write buffer or hitting addr in read buffer (only in case of DMA/page
    // walk) are rare, so not using a big FIFO here
    FIFO#(DramUserReq) reqQ <- mkFIFO;
    // output read resp FIFO
    FIFO#(DramUserData) readRespQ <- mkFIFO;

    // write buffer
    WriteBuffer#(
        maxWriteNum,
        AWSDramMaxUserAddrSz,
        DramUserDataSz
    ) writeBuffer <- mkWriteBuffer;

    // read addr buffer: read addrs in DRAM
    AddrBuffer#(maxReadNum, AWSDramMaxUserAddrSz) rdAddrBuffer <- mkAddrBuffer;

    // FIFO to hold pending loads, either has forwarding result or waiting for
    // DRAM resp.
    FIFO#(Maybe#(DramUserData)) pendReadQ <- mkSizedFIFO(valueof(maxReadNum));

    // sync to AXI master bits pins
`ifdef BSIM
    SimAxi4Dram#(
        AWSDramAxiAddrSz, AWSDramAxiDataSz, AWSDramAxiIdSz,
        AWSDramMaxUserAddrSz, simDelay
    ) axiIfc <- mkSimAxi4Dram;
`else
    Clock userClk <- exposeCurrentClock;
    Reset userRst <- exposeCurrentReset;
    Axi4MasterBitsSync#(
        AWSDramAxiAddrSz, AWSDramAxiDataSz, AWSDramAxiIdSz
    ) axiIfc <- mkAxi4MasterBitsSync(
        userClk, userRst,
        clocked_by dramAxiClk, reset_by dramAxiRst
    );
`endif

    // read req: search for forwrading/stall
    rule doReadReq(reqQ.first.wrBE == 0);
        reqQ.deq;
        DramUserReq req = reqQ.first;
        // check forward or stall
        WrBuffSearchResult#(DramUserDataSz) searchRes = writeBuffer.search(
            truncate(req.addr)
        );
        case(searchRes) matches
            None: begin
                // no forward or stall, req DRAM and save the req
                axiIfc.slave.req_ar.put(Axi4ReadRequest {
                    address: toAWSDramAxiAddr(req.addr),
                    len: 0,
                    size: 6,
                    burst: 1,
                    prot: 0,
                    cache: 3,
                    id: 0, // use same ID to keep resp in order
                    lock: 0,
                    qos: 0
                });
                pendReadQ.enq(Invalid);
                // record addr into read addr buffer
                rdAddrBuffer.enq(truncate(req.addr));
            end
            tagged Forward .data: begin
                // get forwarding, just save forwarded value
                // no need to insert to read addr buffer
                pendReadQ.enq(Valid (data));
            end
            default: begin
                // stall
                when(False, noAction);
            end
        endcase
    endrule

    // write req: insert to write buffer and req DRAM
    rule doWriteReq(reqQ.first.wrBE != 0);
        reqQ.deq;
        DramUserReq req = reqQ.first;
        // search read addr buffer, stall if addr match
        when(!rdAddrBuffer.searchHit(truncate(req.addr)), noAction);
        // insert to write buffer
        writeBuffer.enq(truncate(req.addr), req.data, req.wrBE);
        // req DRAM
        axiIfc.slave.req_aw.put(Axi4WriteRequest {
            address: toAWSDramAxiAddr(req.addr),
            len: 0,
            size: 6,
            burst: 1,
            prot: 0,
            cache: 3,
            id: 0, // use same ID to keep resp in order
            lock: 0,
            qos: 0
        });
        axiIfc.slave.resp_write.put(Axi4WriteData {
            data: req.data,
            byteEnable: req.wrBE,
            last: 1, // only 1 transfer
            id: 0 // use same ID to keep writes in order
        });
    endrule

    // read resp: directly send resp from forwarding
    rule doReadForwardResp(pendReadQ.first matches tagged Valid .data);
        pendReadQ.deq;
        readRespQ.enq(data);
    endrule

    // read resp: from DRAM
    rule doReadDramResp(pendReadQ.first == Invalid);
        pendReadQ.deq;
        rdAddrBuffer.deq;
        let resp <- axiIfc.slave.resp_read.get;
        readRespQ.enq(resp.data);
    endrule

    // write resp from DRAM
    rule doWriteResp;
        let resp <- axiIfc.slave.resp_b.get;
        writeBuffer.deq;
    endrule

    interface DramUser user;
        method Action req(DramUserReq r);
            reqQ.enq(r);
        endmethod
        method ActionValue#(DramUserData) rdResp;
            readRespQ.deq;
            return readRespQ.first;
        endmethod
        method ActionValue#(AWSDramErr) err if(False);
            return ?;
        endmethod
    endinterface

`ifdef BSIM
    interface Empty pins;
    endinterface
`else
    interface AWSDramPins pins;
        interface axiMaster = axiIfc.master;
    endinterface
`endif
endmodule

typedef enum {None, Read, Write} WaitResp deriving(Bits, Eq, FShow);

module mkAWSDramBlockController#(
    Clock dramAxiClk, Reset dramAxiRst
)(
    AWSDramFull#(maxReadNum, maxWriteNum, simDelay)
) provisos(
    Add#(1, a__, maxReadNum),
    Add#(1, b__, maxWriteNum),
    Add#(1, c__, simDelay)
);
    FIFO#(DramUserReq) reqQ <- mkFIFO;
    FIFO#(DramUserData) readRespQ <- mkFIFO;

    // sync to AXI master bits pins
`ifdef BSIM
    SimAxi4Dram#(
        AWSDramAxiAddrSz, AWSDramAxiDataSz, AWSDramAxiIdSz,
        AWSDramMaxUserAddrSz, simDelay
    ) axiIfc <- mkSimAxi4Dram;
`else
    Clock userClk <- exposeCurrentClock;
    Reset userRst <- exposeCurrentReset;
    Axi4MasterBitsSync#(
        AWSDramAxiAddrSz, AWSDramAxiDataSz, AWSDramAxiIdSz
    ) axiIfc <- mkAxi4MasterBitsSync(
        userClk, userRst,
        clocked_by dramAxiClk, reset_by dramAxiRst
    );
`endif

    Reg#(WaitResp) waitResp <- mkReg(None);

    // read req
    rule doReadReq(waitResp == None && reqQ.first.wrBE == 0);
        reqQ.deq;
        DramUserReq req = reqQ.first;
        axiIfc.slave.req_ar.put(Axi4ReadRequest {
            address: toAWSDramAxiAddr(req.addr),
            len: 0,
            size: 6,
            burst: 1,
            prot: 0,
            cache: 3,
            id: 0, // use same ID to keep resp in order
            lock: 0,
            qos: 0
        });
        // wait resp
        waitResp <= Read;
    endrule

    // write req: insert to write buffer and req DRAM
    rule doWriteReq(waitResp == None && reqQ.first.wrBE != 0);
        reqQ.deq;
        DramUserReq req = reqQ.first;
        axiIfc.slave.req_aw.put(Axi4WriteRequest {
            address: toAWSDramAxiAddr(req.addr),
            len: 0,
            size: 6,
            burst: 1,
            prot: 0,
            cache: 3,
            id: 0, // use same ID to keep writes in order
            lock: 0,
            qos: 0
        });
        axiIfc.slave.resp_write.put(Axi4WriteData {
            data: req.data,
            byteEnable: req.wrBE,
            last: 1, // only 1 transfer
            id: 0 // use same ID to keep writes in order
        });
        // wait resp
        waitResp <= Write;
    endrule

    // read resp
    rule doReadDramResp(waitResp == Read);
        let resp <- axiIfc.slave.resp_read.get;
        readRespQ.enq(resp.data);
        waitResp <= None;
    endrule

    // write resp from DRAM
    rule doWriteResp(waitResp == Write);
        let resp <- axiIfc.slave.resp_b.get;
        waitResp <= None;
    endrule

    interface DramUser user;
        method Action req(DramUserReq r);
            reqQ.enq(r);
        endmethod
        method ActionValue#(DramUserData) rdResp;
            readRespQ.deq;
            return readRespQ.first;
        endmethod
        method ActionValue#(AWSDramErr) err if(False);
            return ?;
        endmethod
    endinterface

`ifdef BSIM
    interface Empty pins;
    endinterface
`else
    interface AWSDramPins pins;
        interface axiMaster = axiIfc.master;
    endinterface
`endif
endmodule
