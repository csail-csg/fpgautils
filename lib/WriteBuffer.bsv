import Vector::*;
import Ehr::*;

// write buffer to interface AXI
// AXI keeps St->St, Ld->Ld ordering by assign same IDs
// this can help keep St-->Ld (same addr) ordering

// bypass result
typedef union tagged {
    void None;
    Bit#(dataSz) Forward;
    void Stall;
} WrBuffSearchResult#(numeric type dataSz) deriving(Bits, Eq, FShow);

interface WriteBuffer#(
    numeric type buffSz,
    numeric type addrSz,
    numeric type dataSz
);
    // search from youngest to oldest for forward or stall
    method WrBuffSearchResult#(dataSz) search(Bit#(addrSz) addr);
    // enq in order
    method Action enq(
        Bit#(addrSz) addr, Bit#(dataSz) data, Bit#(TDiv#(dataSz, 8)) wrBE
    );
    // deq oldest write
    method Action deq;
endinterface

// in order write buffer: bypass < enq < deq
module mkWriteBuffer(WriteBuffer#(buffSz, addrSz, dataSz)) provisos (
    Add#(1, a__, buffSz),
    Alias#(elemCntT, Bit#(TLog#(TAdd#(buffSz, 1)))),
    NumAlias#(beSz, TDiv#(dataSz, 8)),
    Mul#(beSz, 8, dataSz)
);
    // youngest req is always in addr/dataVec[0]
    Vector#(buffSz, Reg#(Bit#(addrSz))) addrVec <- replicateM(mkRegU);
    Vector#(buffSz, Reg#(Bit#(dataSz))) dataVec <- replicateM(mkRegU);
    Vector#(buffSz, Reg#(Bool)) fullWriteVec <- replicateM(mkRegU); // whether write covers whole line

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

    method WrBuffSearchResult#(dataSz) search(Bit#(addrSz) addr);
        // Search from YOUNGEST (index 0). May stall or forward.
        WrBuffSearchResult#(dataSz) res = None;
        elemCntT cur_cnt = cnt[cnt_search_port];
        for(Integer i = 0; i < valueOf(buffSz); i = i+1) begin
            if(res == None && fromInteger(i) < cur_cnt && addrVec[i] == addr) begin
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

    method Action enq(
        Bit#(addrSz) addr, Bit#(dataSz) data, Bit#(beSz) wrBE
    ) if(isNotFull);
        // insert new req into position 0, and shift older req backwards
        for(Integer i = 1; i < valueOf(buffSz); i = i+1) begin
            addrVec[i] <= addrVec[i - 1];
            dataVec[i] <= dataVec[i - 1];
            fullWriteVec[i] <= fullWriteVec[i - 1];
        end
        addrVec[0] <= addr;
        dataVec[0] <= data;
        fullWriteVec[0] <= wrBE == maxBound;
        // incr buffer cnt
        cnt[cnt_enq_port] <= cnt[cnt_enq_port] + 1;
    endmethod

    method Action deq if(isNotEmpty);
        // decr buffer cnt
        cnt[cnt_deq_port] <= cnt[cnt_deq_port] - 1;
    endmethod
endmodule

