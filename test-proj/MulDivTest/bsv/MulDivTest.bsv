`include "ConnectalProjectConfig.bsv"

import Clocks::*;
import FIFO::*;
import BRAMFIFO::*;
import SyncFifo::*;
import MulDivTestIF::*;
import XilinxIntMul::*;
import XilinxIntDiv::*;

(* synthesize *)
module mkMul(XilinxIntMul#(UserTag));
    let m <- mkXilinxIntMul;
    return m;
endmodule

(* synthesize *)
module mkDivSigned(XilinxIntDiv#(UserTag));
    let m <- mkXilinxIntDivSigned;
    return m;
endmodule

(* synthesize *)
module mkDivUnsigned(XilinxIntDiv#(UserTag));
    let m <- mkXilinxIntDivUnsigned;
    return m;
endmodule

interface MulDivTest;
    method Action setTest(MulDivReq r, Bool last);
    method ActionValue#(MulDivResp) resp;
endinterface

// maximum tests
typedef `MAX_TEST_NUM MaxTestNum;

// delay certain cycles after seeing all responses for a test to create back
// pressure
typedef Bit#(`LOG_DELAY_CYCLES) DelayCnt;

(* synthesize *)
module mkMulDivTest#(Clock portalClk, Reset portalRst)(MulDivTest);
    // sync in/out
    Clock curClk <- exposeCurrentClock;
    Reset curRst <- exposeCurrentReset;
    SyncFIFOIfc#(Tuple2#(MulDivReq, Bool)) setTestQ <- mkSyncFifo(
        1, portalClk, portalRst, curClk, curRst
    );
    SyncFIFOIfc#(MulDivResp) respQ <- mkSyncFifo(
        1, curClk, curRst, portalClk, portalRst
    );
    
    // tests
    FIFO#(MulDivReq) testQ <- mkSizedBRAMFIFO(valueof(MaxTestNum));
    Reg#(Bool) started <- mkReg(False);

    // delay resp
    Reg#(DelayCnt) delay <- mkReg(0);

    // mul/div units
    XilinxIntMul#(UserTag) mul <- mkMul;
    XilinxIntDiv#(UserTag) divSigned <- mkDivSigned;
    XilinxIntDiv#(UserTag) divUnsigned <- mkDivUnsigned;

    rule doSetTest(!started);
        setTestQ.deq;
        let {req, last} = setTestQ.first;
        started <= last;
        testQ.enq(req);
    endrule

    rule sendTest(started);
        testQ.deq;
        let r = testQ.first;
        XilinxIntMulSign sign = (case(r.sign)
            Signed: (Signed);
            Unsigned: (Unsigned);
            SignedUnsigned: (SignedUnsigned);
            default: (?);
        endcase);
        mul.req(r.a, r.b, sign, r.tag);
        divSigned.req(r.a, r.b, r.tag);
        divUnsigned.req(r.a, r.b, r.tag);
    endrule

    rule delayResp(
        mul.respValid && divSigned.respValid &&
        divUnsigned.respValid && delay < maxBound
    );
        delay <= delay + 1;
    endrule

    rule recvResp(delay == maxBound);
        mul.deqResp;
        divSigned.deqResp;
        divUnsigned.deqResp;

        let resp = MulDivResp {
            productHi: truncateLSB(mul.product),
            productLo: truncate(mul.product),
            mulTag: mul.respTag,
            quotientSigned: divSigned.quotient,
            remainderSigned: divSigned.remainder,
            divSignedTag: divSigned.respTag,
            quotientUnsigned: divUnsigned.quotient,
            remainderUnsigned: divUnsigned.remainder,
            divUnsignedTag: divUnsigned.respTag
        };
        respQ.enq(resp);
        delay <= 0; // reset delay
    endrule

    method Action setTest(MulDivReq r, Bool last);
        setTestQ.enq(tuple2(r, last));
    endmethod

    method ActionValue#(MulDivResp) resp;
        respQ.deq;
        return respQ.first;
    endmethod
endmodule
