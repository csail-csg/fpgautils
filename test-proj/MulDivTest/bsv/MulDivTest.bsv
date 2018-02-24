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
module mkDiv(XilinxIntDiv#(UserTag));
    let m <- mkXilinxIntDiv;
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
    XilinxIntMul#(UserTag) mulUnit <- mkMul;
    XilinxIntDiv#(UserTag) divUnit <- mkDiv;

    rule doSetTest(!started);
        setTestQ.deq;
        let {req, last} = setTestQ.first;
        started <= last;
        testQ.enq(req);
    endrule

    rule sendTest(started);
        testQ.deq;
        let r = testQ.first;
        XilinxIntMulSign mulSign = (case(r.mulSign)
            Signed: (Signed);
            Unsigned: (Unsigned);
            SignedUnsigned: (SignedUnsigned);
            default: (?);
        endcase);
        mulUnit.req(r.a, r.b, mulSign, r.tag);
        divUnit.req(r.a, r.b, r.divSigned, r.tag);
    endrule

    rule delayResp(
        mulUnit.respValid && divUnit.respValid && delay < maxBound
    );
        delay <= delay + 1;
    endrule

    rule recvResp(delay == maxBound);
        mulUnit.deqResp;
        divUnit.deqResp;

        let resp = MulDivResp {
            productHi: truncateLSB(mulUnit.product),
            productLo: truncate(mulUnit.product),
            mulTag: mulUnit.respTag,
            quotient: divUnit.quotient,
            remainder: divUnit.remainder,
            divTag: divUnit.respTag
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
