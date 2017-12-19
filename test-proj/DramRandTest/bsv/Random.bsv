import LFSR::*;
import Vector::*;
import DramCommon::*;
import DRTestIF::*;

interface RandNum#(numeric type n);
    method ActionValue#(Bit#(n)) getVal;
    method Action seed(Bit#(32) s);
endinterface

(* synthesize *)
module mkRandDramUserData(RandNum#(DramUserDataSz));
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32;

    method ActionValue#(DramUserData) getVal;
        lfsr.next;
        Bit#(32) r = lfsr.value;
        Vector#(TDiv#(DramUserDataSz, 32), Bit#(32)) v = replicate(r);
        return pack(v);
    endmethod

    method seed = lfsr.seed;
endmodule

(* synthesize *)
module mkRandDramUserBE(RandNum#(DramUserBESz));
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32;

    method ActionValue#(DramUserBE) getVal;
        lfsr.next;
        Bit#(32) r = lfsr.value;
        Bool isRead = r[15] == 0; // select some middle bit...
        if(isRead) begin
            return 0;
        end
        else begin
            Vector#(TDiv#(DramUserBESz, 32), Bit#(32)) v = replicate(r);
            return pack(v);
        end
    endmethod

    method seed = lfsr.seed;
endmodule

(* synthesize *)
module mkRandAddrIdx(RandNum#(LogMaxAddrNum));
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32;

    method ActionValue#(TestAddrIdx) getVal;
        lfsr.next;
        return truncate(lfsr.value);
    endmethod

    method seed = lfsr.seed;
endmodule



// get 0,1 random, with a x/2^n ratio to return 1
interface RandRatio#(numeric type n);
    method Action setRatio(Bit#(n) x);
    method Bool value;
endinterface

module mkRandRatio(RandRatio#(n)) provisos(Add#(n, a__, 32));
    LFSR#(Bit#(32)) lfsr <- mkLFSR_32;
    Reg#(Bit#(n)) threshold <- mkReg(0);

    rule doNext;
        lfsr.next;
    endrule

    method Action setRatio(Bit#(n) x);
        threshold <= x;
    endmethod

    method Bool value;
        Bit#(n) v = truncateLSB(lfsr.value);
        return v < threshold;
    endmethod
endmodule


typedef `LOG_STALL_RATIO LogStallRatio;

(* synthesize *)
module mkRandStall(RandRatio#(LogStallRatio));
    let m <- mkRandRatio;
    return m;
endmodule
