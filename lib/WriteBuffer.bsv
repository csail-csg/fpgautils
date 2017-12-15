import Vector::*;

import DramUserCommon::*;
import Types::*; // for asssertion

// write buffer to interface AXI
// AXI keeps St->St, Ld->Ld ordering by assign same IDs
// this can help keep St-->Ld (same addr) ordering
interface WriteBuffer#(numeric type sz);
    // bypass data from the youngest matching St req
    method Maybe#(DramUserData) bypass(DramUserAddr addr);
    method Bool notFull;
    method Action enq(DramUserReq r);
    method Bool notEmpty;
    method Action deq;
endinterface

module mkWriteBuffer(WriteBuffer#(buffSz)) provisos (
    Add#(1, a__, buffSz),
    Alias#(elemCnt, Bit#(TLog#(TAdd#(buffSz, 1))))
);
    // youngest req is always in addr/dataVec[0]
    Vector#(buffSz, Reg#(DramUserAddr)) addrVec <- replicateM(mkRegU);
    Vector#(buffSz, Reg#(DramUserData)) dataVec <- replicateM(mkRegU);
    Vector#(buffSz, Reg#(Bool)) fullWriteVec <- replicateM(mkRegU); // whether write covers whole line
    Reg#(elemCnt) cnt <- mkReg(0); // number of valid req

    RWire#(DramUserReq) enqReq <- mkRWire;
    PulseWire deqReq <- mkPulseWire;

    (* fire_when_enabled, no_implicit_conditions *)
    rule canon;
        // insert new req into position 0
        // and shift older req backwards
        if(enqReq.wget matches tagged Valid .req) begin
            for(Integer i = 1; i < valueOf(buffSz); i = i+1) begin
                addrVec[i] <= addrVec[i - 1];
                dataVec[i] <= dataVec[i - 1];
                fullWriteVec[i] <= fullWriteVec[i - 1];
            end
            addrVec[0] <= req.addr;
            dataVec[0] <= req.data;
            fullWriteVec[0] <= req.wrBe == maxBound;
        end
        // change valid req number
        elemCnt cntNext = cnt;
        if(isValid(enqReq[1])) begin
            cntNext = cntNext + 1;
        end
        if(deqReq[1]) begin
            cntNext = cntNext - 1;
        end
        cnt <= cntNext;
    endrule

    method Maybe#(CacheLine) bypass(CLineAddr cAddr);
        // bypass from YOUNGEST
        // We may also stall by partial forwarding
        Maybe#(DramUserData) hit = Invalid;
        Bool stall = False;
        for(Integer i = 0; i < valueOf(buffSz); i = i+1) begin
            if(!isValid(hit) && !stall && fromInteger(i) < cnt && addrVec[i] == cAddr) begin
                if(fullWriteVec[i]) begin
                    hit = Valid (dataVec[i]);
                end
                else begin
                    stall = True;
                end
            end
        end
        return hit;
    endmethod

    method Bool notFull = cnt < fromInteger(valueOf(buffSz));

    method Action enq(DramUserReq req) if(cnt < fromInteger(valueOf(buffSz)));
        doAssert(req.wrBE != 0, "only write req can get into write buffer");
        enqReq.wset(req);
    endmethod

    method Bool notEmpty = cnt > 0;

    method Action deq if(cnt > 0);
        deqReq.send;
    endmethod
endmodule

