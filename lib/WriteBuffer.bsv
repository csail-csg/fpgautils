import Vector::*;

import DramCommon::*;

// write buffer to interface AXI
// AXI keeps St->St, Ld->Ld ordering by assign same IDs
// this can help keep St-->Ld (same addr) ordering

typedef union tagged {
    void None;
    DramUserData Forward;
    void Stall;
} WrBuffBypassResult deriving(Bits, Eq, FShow);

interface WriteBuffer#(numeric type buffSz, numeric type addrSz);
    // bypass data from the youngest matching St req
    method WrBuffBypassResult bypass(Bit#(addrSz) addr);
    method Bool notFull;
    method Action enq(Bit#(addrSz) addr, DramUserData data, DramUserBE wrBE);
    method Bool notEmpty;
    method Action deq;
endinterface

module mkWriteBuffer(WriteBuffer#(buffSz, addrSz)) provisos (
    Add#(1, a__, buffSz),
    Alias#(elemCnt, Bit#(TLog#(TAdd#(buffSz, 1))))
);
    // youngest req is always in addr/dataVec[0]
    Vector#(buffSz, Reg#(Bit#(addrSz))) addrVec <- replicateM(mkRegU);
    Vector#(buffSz, Reg#(DramUserData)) dataVec <- replicateM(mkRegU);
    Vector#(buffSz, Reg#(Bool)) fullWriteVec <- replicateM(mkRegU); // whether write covers whole line
    Reg#(elemCnt) cnt <- mkReg(0); // number of valid req

    RWire#(Tuple3#(Bit#(addrSz), DramUserData, DramUserBE)) enqReq <- mkRWire;
    PulseWire deqReq <- mkPulseWire;

    (* fire_when_enabled, no_implicit_conditions *)
    rule canon;
        // insert new req into position 0
        // and shift older req backwards
        if(enqReq.wget matches tagged Valid {.addr, .data, .wrBE}) begin
            for(Integer i = 1; i < valueOf(buffSz); i = i+1) begin
                addrVec[i] <= addrVec[i - 1];
                dataVec[i] <= dataVec[i - 1];
                fullWriteVec[i] <= fullWriteVec[i - 1];
            end
            addrVec[0] <= addr;
            dataVec[0] <= data;
            fullWriteVec[0] <= wrBE == maxBound;
        end
        // change valid req number
        elemCnt cntNext = cnt;
        if(isValid(enqReq.wget)) begin
            cntNext = cntNext + 1;
        end
        if(deqReq) begin
            cntNext = cntNext - 1;
        end
        cnt <= cntNext;
    endrule

    method WrBuffBypassResult bypass(Bit#(addrSz) addr);
        // bypass from YOUNGEST
        // We may also stall by partial forwarding
        WrBuffBypassResult res = None;
        for(Integer i = 0; i < valueOf(buffSz); i = i+1) begin
            if(res == None && fromInteger(i) < cnt && addrVec[i] == addr) begin
                if(fullWriteVec[i]) begin
                    res = Forward (dataVec[i]);
                end
                else begin
                    res = Stall;
                end
            end
        end
        return res;
    endmethod

    method Bool notFull = cnt < fromInteger(valueOf(buffSz));

    method Action enq(
        Bit#(addrSz) addr, DramUserData data, DramUserBE wrBE
    ) if(cnt < fromInteger(valueOf(buffSz)));
        enqReq.wset(tuple3(addr, data, wrBE));
        doAssert(wrBE != 0, "Only write can be added to write buffer");
    endmethod

    method Bool notEmpty = cnt > 0;

    method Action deq if(cnt > 0);
        deqReq.send;
    endmethod
endmodule

