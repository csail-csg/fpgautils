
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
import Clocks::*;

import AxiBits::*;
import Axi4MasterSlave::*;

import SyncFifo::*;

// This module sync from user clock domain to AXI master bits (pins) domain. It
// provides user with a AXI slave interface, and also outputs a master bits
// (pins) interface.

// This module should be clocked under the master bits clock domain.

interface Axi4MasterBitsSync#(
    numeric type addrSz,
    numeric type dataSz,
    numeric type idSz
);
    interface Axi4Slave#(addrSz, dataSz, idSz) slave;
    interface Axi4MasterBits#(addrSz, dataSz, idSz, Empty) master;
endinterface

module mkAxi4MasterBitsSync#(
    Clock slaveClk,
    Reset slaveRst
)(Axi4MasterBitsSync#(addrSz, dataSz, idSz)) provisos(
    Alias#(rdReqT, Axi4ReadRequest#(addrSz, idSz)),
    Alias#(rdRespT, Axi4ReadResponse#(dataSz, idSz)),
    Alias#(wrReqT, Axi4WriteRequest#(addrSz, idSz)),
    Alias#(wrDataT, Axi4WriteData#(dataSz, idSz)),
    Alias#(wrRespT, Axi4WriteResponse#(idSz))
);

    Clock masterClk <- exposeCurrentClock;
    Reset masterRst <- exposeCurrentReset;

    SyncFIFOIfc#(rdReqT) arfifo <- mkSyncFifo(2, slaveClk, slaveRst, masterClk, masterRst);
    let araddrWire <- mkDWire(0);
    let arburstWire <- mkDWire(0);
    let arcacheWire <- mkDWire(0);
    let aridWire <- mkDWire(0);
    let arreadyWire <- mkDWire(False);
    let arprotWire <- mkDWire(0);
    let arlenWire <- mkDWire(0);
    let arsizeWire <- mkDWire(0);
    let arlockWire <- mkDWire(0);
    let arqosWire <- mkDWire(0);

    SyncFIFOIfc#(wrReqT) awfifo <- mkSyncFifo(2, slaveClk, slaveRst, masterClk, masterRst);
    let awaddrWire <- mkDWire(0);
    let awburstWire <- mkDWire(0);
    let awcacheWire <- mkDWire(0);
    let awidWire <- mkDWire(0);
    let awreadyWire <- mkDWire(False);
    let awprotWire <- mkDWire(0);
    let awlenWire <- mkDWire(0);
    let awsizeWire <- mkDWire(0);
    let awlockWire <- mkDWire(0);
    let awqosWire <- mkDWire(0);

    SyncFIFOIfc#(rdRespT) rfifo <- mkSyncFifo(2, masterClk, masterRst, slaveClk, slaveRst);
    let rdataWire <- mkDWire(0);
    let rrespWire <- mkDWire(0);
    let rlastWire <- mkDWire(0);
    let ridWire <- mkDWire(0);      
    let rvalidWire <- mkDWire(False);

    SyncFIFOIfc#(wrDataT) wfifo <- mkSyncFifo(2, slaveClk, slaveRst, masterClk, masterRst);
    let wdataWire <- mkDWire(0);
    let widWire <- mkDWire(0);
    let wstrbWire <- mkDWire(0);
    let wlastWire <- mkDWire(0);
    let wreadyWire <- mkDWire(False);

    SyncFIFOIfc#(wrRespT) bfifo <- mkSyncFifo(2, masterClk, masterRst, slaveClk, slaveRst);
    let bidWire <- mkDWire(0);
    let brespWire <- mkDWire(0);
    let bvalidWire <- mkDWire(False);

    // req req addr
    (* fire_when_enabled *)
    rule arwire_rule;
        araddrWire  <= arfifo.first.address;
        arlenWire   <= arfifo.first.len;
        arsizeWire  <= arfifo.first.size;
        arburstWire <= arfifo.first.burst;
        arprotWire  <= arfifo.first.prot;
        arcacheWire <= arfifo.first.cache;
        aridWire    <= arfifo.first.id;
        arlockWire  <= arfifo.first.lock;
        arqosWire   <= arfifo.first.qos;
    endrule

    (* fire_when_enabled *)
    rule ar_handshake(arreadyWire);
        arfifo.deq;
    endrule

    // write req addr
    (* fire_when_enabled *)
    rule awwire_rule;
        awaddrWire  <= awfifo.first.address;
        awlenWire   <= awfifo.first.len;
        awsizeWire  <= awfifo.first.size;
        awburstWire <= awfifo.first.burst;
        awprotWire  <= awfifo.first.prot;
        awcacheWire <= awfifo.first.cache;
        awidWire    <= awfifo.first.id;
        awlockWire  <= awfifo.first.lock;
        awqosWire   <= awfifo.first.qos;
    endrule

    (* fire_when_enabled *)
    rule aw_handshake(awreadyWire);
        awfifo.deq;
    endrule

    // read resp
    (* fire_when_enabled *)
    rule r_handshake(rvalidWire);
        rfifo.enq(Axi4ReadResponse {
            data: rdataWire,
            resp: rrespWire,
            last: rlastWire,
            id  : ridWire
        });
    endrule

    // write req data
    (* fire_when_enabled *)
    rule wwire_rule;
        wdataWire <= wfifo.first.data;
        wstrbWire <= wfifo.first.byteEnable;
        wlastWire <= wfifo.first.last;
        widWire   <= wfifo.first.id;
    endrule

    (* fire_when_enabled *)
    rule w_handshake(wreadyWire);
        wfifo.deq;
    endrule

    // write resp
    (* fire_when_enabled *)
    rule b_handshake(bvalidWire);
        bfifo.enq(Axi4WriteResponse {
            resp: brespWire,
            id  : bidWire
        });
    endrule

    interface Axi4Slave slave;
        interface Put req_ar = toPut(arfifo);
        interface Get resp_read = toGet(rfifo);
        interface Put req_aw = toPut(awfifo);
        interface Put resp_write = toPut(wfifo);
        interface Get resp_b = toGet(bfifo);
    endinterface

    interface Axi4MasterBits master;
        method aresetn = 1;
        method araddr  = araddrWire;
        method arburst = arburstWire;
        method arcache = arcacheWire;
        method arid    = aridWire;
        method arlen   = arlenWire;
        method arlock  = arlockWire;
        method arprot  = arprotWire;
        method arqos   = arqosWire;
        method arsize  = arsizeWire;
        method arvalid = pack(arfifo.notEmpty);
        method Action arready(Bit#(1) v); arreadyWire <= unpack(v); endmethod

        method awaddr  = awaddrWire;
        method awburst = awburstWire;
        method awcache = awcacheWire;
        method awid    = awidWire;
        method awlen   = awlenWire;
        method awlock  = awlockWire;
        method awprot  = awprotWire;
        method awqos   = awqosWire;
        method awsize  = awsizeWire;
        method awvalid = pack(awfifo.notEmpty);
        method Action awready(Bit#(1) v); awreadyWire <= unpack(v); endmethod

        method bready = pack(bfifo.notFull);
        method Action bid(Bit#(idSz) v); bidWire <= v; endmethod
        method Action bresp(Bit#(2) v);  brespWire <= v; endmethod
        method Action bvalid(Bit#(1) v); bvalidWire <= unpack(v); endmethod

        method rready = pack(rfifo.notFull);
        method Action rdata(Bit#(dataSz) v); rdataWire <= v; endmethod
        method Action rid(Bit#(idSz) v);     ridWire <= v; endmethod
        method Action rlast(Bit#(1) v);      rlastWire <= unpack(v); endmethod
        method Action rresp(Bit#(2) v);      rrespWire <= v; endmethod
        method Action rvalid(Bit#(1) v);     rvalidWire <= unpack(v); endmethod

        method wdata  = wdataWire;
        method wid    = widWire;
        method wlast  = wlastWire;
        method wstrb  = wstrbWire;
        method wvalid = pack(wfifo.notEmpty);
        method Action wready(Bit#(1) v); wreadyWire <= unpack(v); endmethod

        interface Empty extra;
        endinterface
    endinterface
endmodule
