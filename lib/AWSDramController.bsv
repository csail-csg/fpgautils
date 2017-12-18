import GetPut::*;
import BRAMFIFO::*;
import FIFO::*;

import Axi4MasterSlave::*;
import AxiBits::*;

import DramCommon::*;
import AWSDramCommon::*;
import WriteBuffer::*;
import Axi4MasterBitsSync::*;
import SimAxiDram::*;

export mkAWSDramController;

`ifdef BSIM
typedef 24 AWSDramMaxUserAddrSz; // simulation: 1GB
`else
typedef 28 AWSDramMaxUserAddrSz; // F1 FPGA: 16GB
`endif

function Bool addrOverflow(DramUserAddr a);
    Bit#(AWSDramMaxUserAddrSz) mask = maxBound;
    return (a & ~zeroExtend(mask)) != 0;
endfunction

function AWSDramAxiAddr toAWSDramAxiAddr(DramUserAddr a);
    return {a, 6'b0};
endfunction

module mkAWSDramController#(
    Clock dramAxiClk, Reset dramAxiRst, Bool useBramPendReadQ
)(
    AWSDramFull#(maxReadNum, maxWriteNum, simDelay)
) provisos(
    Add#(1, a__, maxReadNum),
    Add#(1, b__, maxWriteNum),
    Add#(1, c__, simDelay)
);
    // a shallow FIFO to buffer req; we assume stalling by partial forwarding
    // in write buffer is rare, so not using a big FIFO here
    FIFO#(DramUserReq) reqQ <- mkFIFO;
    // output read resp FIFO
    FIFO#(DramUserData) readRespQ <- mkFIFO;
    // output err FIFO
    FIFO#(AWSDramErr) errQ <- mkFIFO;

    // write buffer
    WriteBuffer#(maxWriteNum, AWSDramMaxUserAddrSz) writeBuffer <- mkWriteBuffer;

    // FIFO to hold pending loads, either has forwarding result or waiting for
    // DRAM resp.
    FIFO#(Maybe#(DramUserData)) pendReadQ;
    if(useBramPendReadQ) begin
        pendReadQ <- mkSizedBRAMFIFO(valueof(maxReadNum));
    end
    else begin
        pendReadQ <- mkSizedFIFO(valueof(maxReadNum));
    end

    // sync to AXI master bits pins
`ifdef BSIM
    SimAxi4Dram#(
        AWSDramAxiAddrSz, AWSDramAxiDataSz, AWSDramAxiIdSz,
        AWSDramMaxUserAddrSz, simDelay
    ) axiIfc <- mkSimAxi4Dram;
`else
    Axi4MasterBitsSync#(
        AWSDramAxiAddrSz, AWSDramAxiDataSz, AWSDramAxiIdSz
    ) axiIfc <- mkAxi4MasterBitsSync(
        clocked_by dramAxiClk, reset_by dramAxiRst
    );
`endif

    // read req: search for forwrading/stall
    rule doReadReq(reqQ.first.wrBE == 0);
        reqQ.deq;
        DramUserReq req = reqQ.first;
        // check addr overflow
        if(addrOverflow(req.addr)) begin
            errQ.enq(AddrOverflow);
            doAssert(False, "Dram read addr overflow");
        end
        // check forward or stall
        WrBuffBypassResult bypassRes = writeBuffer.bypass(truncate(req.addr));
        case(bypassRes) matches
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
            end
            tagged Forward .data: begin
                // get forwarding, save forwarded value
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
        // check addr overflow
        if(addrOverflow(req.addr)) begin
            errQ.enq(AddrOverflow);
            doAssert(False, "Dram write addr overflow");
        end
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
    endrule

    // read resp: directly send resp from forwarding
    rule doReadForwardResp(pendReadQ.first matches tagged Valid .data);
        pendReadQ.deq;
        readRespQ.enq(data);
    endrule

    // read resp: from DRAM
    rule doReadDramResp(pendReadQ.first == Invalid);
        pendReadQ.deq;
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
        method ActionValue#(AWSDramErr) err;
            errQ.deq;
            return errQ.first;
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
