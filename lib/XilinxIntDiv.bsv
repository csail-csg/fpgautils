import FIFOF::*;
import FIFO::*;

import WaitAutoReset::*;

export XilinxIntDiv(..);
export mkXilinxIntDivSigned;
export mkXilinxIntDivUnsigned;

// xilinx ip cores import ifc
interface IntDivImport#(type userT);
    method Action enqDividend(Bit#(64) dividend, userT user);
    method Action enqDivisor(Bit#(64) divisor);
    method Action deqResp;
    method Bool respValid;
    method Bit#(128) quotient_remainder;
    method userT respUser;
endinterface

// import Xilinx IP core for signed division

// axi tuser: user tag + info needed to handle overflow or divide by 0
typedef struct {
    Bool overflow;
    Bool divideZero;
    Bit#(64) dividend;
    Bit#(8) tag;
} IntDivSignedUser deriving(Bits, Eq, FShow);

import "BVI" int_div_signed =
module mkIntDivSignedImport(IntDivImport#(IntDivSignedUser));
    default_clock clk(aclk, (*unused*) unused_gate);
    default_reset no_reset;

    method enqDividend(
        s_axis_dividend_tdata, s_axis_dividend_tuser
    ) enable(s_axis_dividend_tvalid) ready(s_axis_dividend_tready);

    method enqDivisor(
        s_axis_divisor_tdata
    ) enable(s_axis_divisor_tvalid) ready(s_axis_divisor_tready);

    method deqResp() enable(m_axis_dout_tready) ready(m_axis_dout_tvalid);
    method m_axis_dout_tvalid respValid;
    method m_axis_dout_tdata quotient_remainder ready(m_axis_dout_tvalid);
    method m_axis_dout_tuser respUser ready(m_axis_dout_tvalid);

    schedule (enqDividend) C (enqDividend);
    schedule (enqDivisor) C (enqDivisor);
    schedule (deqResp) C (deqResp);
    schedule (enqDividend) CF (enqDivisor, deqResp);
    schedule (enqDivisor) CF (deqResp);
    schedule (
        respValid,
        quotient_remainder,
        respUser
    ) CF (
        respValid,
        quotient_remainder,
        respUser,
        enqDividend,
        enqDivisor,
        deqResp
    );
endmodule

// import Xilinx IP core for unsigned division

// axi tuser: user tag + info needed to handle divide by 0
typedef struct {
    Bool divideZero;
    Bit#(64) dividend;
    Bit#(8) tag;
} IntDivUnsignedUser deriving(Bits, Eq, FShow);

import "BVI" int_div_unsigned =
module mkIntDivUnsignedImport(IntDivImport#(IntDivUnsignedUser));
    default_clock clk(aclk, (*unused*) unused_gate);
    default_reset no_reset;

    method enqDividend(
        s_axis_dividend_tdata, s_axis_dividend_tuser
    ) enable(s_axis_dividend_tvalid) ready(s_axis_dividend_tready);

    method enqDivisor(
        s_axis_divisor_tdata
    ) enable(s_axis_divisor_tvalid) ready(s_axis_divisor_tready);

    method deqResp() enable(m_axis_dout_tready) ready(m_axis_dout_tvalid);
    method m_axis_dout_tvalid respValid;
    method m_axis_dout_tdata quotient_remainder ready(m_axis_dout_tvalid);
    method m_axis_dout_tuser respUser ready(m_axis_dout_tvalid);

    schedule (enqDividend) C (enqDividend);
    schedule (enqDivisor) C (enqDivisor);
    schedule (deqResp) C (deqResp);
    schedule (enqDividend) CF (enqDivisor, deqResp);
    schedule (enqDivisor) CF (deqResp);
    schedule (
        respValid,
        quotient_remainder,
        respUser
    ) CF (
        respValid,
        quotient_remainder,
        respUser,
        enqDividend,
        enqDivisor,
        deqResp
    );
endmodule

// simulation
module mkIntDivSim#(Bool isUnsign)(IntDivImport#(userT)) provisos(
    Bits#(userT, userSz)
);
    FIFO#(Tuple2#(Bit#(64), userT)) dividendQ <- mkFIFO;
    FIFO#(Bit#(64)) divisorQ <- mkFIFO;
    FIFOF#(Tuple2#(Bit#(128), userT)) respQ <- mkSizedFIFOF(2);

    rule compute;
        dividendQ.deq;
        divisorQ.deq;
        let {dividend, user} = dividendQ.first;
        let divisor = divisorQ.first;

        Bit#(64) q; // quotient
        Bit#(64) r; // remainder
        if(isUnsign) begin
            UInt#(64) a = unpack(dividend);
            UInt#(64) b = unpack(divisor);
            q = pack(a / b);
            r = pack(a % b);
        end
        else begin
            Int#(64) a = unpack(dividend);
            Int#(64) b = unpack(divisor);
            q = pack(a / b);
            r = pack(a % b);
        end
        respQ.enq(tuple2({q, r}, user));
    endrule

    method Action enqDividend(Bit#(64) dividend, userT user);
        dividendQ.enq(tuple2(dividend, user));
    endmethod

    method Action enqDivisor(Bit#(64) divisor);
        divisorQ.enq(divisor);
    endmethod

    method Action deqResp;
        respQ.deq;
    endmethod

    method respValid = respQ.notEmpty;

    method quotient_remainder = tpl_1(respQ.first);

    method respUser = tpl_2(respQ.first);
endmodule


// Wrapper for user (add reset guard, check overflow/divided by 0).  We cannot
// unify two dividers to one, because divider latency may not be a constant.
interface XilinxIntDiv#(type tagT);
    method Action req(Bit#(64) dividend, Bit#(64) divisor, tagT tag);
    // response
    method Action deqResp;
    method Bool respValid;
    method Bit#(64) quotient;
    method Bit#(64) remainder;
    method tagT respTag;
endinterface

module mkXilinxIntDivSigned(XilinxIntDiv#(tagT)) provisos (
    Bits#(tagT, tagSz), Add#(tagSz, a__, 8)
);
`ifdef BSIM
    IntDivImport#(IntDivSignedUser) divIfc <- mkIntDivSim(False);
`else
    IntDivImport#(IntDivSignedUser) divIfc <- mkIntDivSignedImport;
`endif
    WaitAutoReset#(4) init <- mkWaitAutoReset;

    method Action req(
        Bit#(64) dividend, Bit#(64) divisor, tagT tag
    ) if(init.isReady);
        let user = IntDivSignedUser {
            overflow: dividend == {1'b1, 63'b0} && divisor == maxBound,
            divideZero: divisor == 0,
            dividend: dividend,
            tag: zeroExtend(pack(tag))
        };
        divIfc.enqDividend(dividend, user);
        divIfc.enqDivisor(divisor);
    endmethod

    // we also put reset guard on deq port to prevent random signals before
    // reset from dequing or corrupting axi states
    method Action deqResp if(init.isReady);
        divIfc.deqResp;
    endmethod

    method respValid = divIfc.respValid && init.isReady;
    
    method Bit#(64) quotient if(init.isReady);
        let user = divIfc.respUser;
        Bit#(64) q;
        if(user.overflow) begin
            q = {1'b1, 63'b0};
        end
        else if(user.divideZero) begin
            q = maxBound; // -1
        end
        else begin
            q = truncateLSB(divIfc.quotient_remainder);
        end
        return q;
    endmethod
    
    method Bit#(64) remainder if(init.isReady);
        let user = divIfc.respUser;
        Bit#(64) r;
        if(user.overflow) begin
            r = 0;
        end
        else if(user.divideZero) begin
            r = user.dividend;
        end
        else begin
            r = truncate(divIfc.quotient_remainder);
        end
        return r;
    endmethod 

    method tagT respTag if(init.isReady);
        return unpack(truncate(divIfc.respUser.tag));
    endmethod
endmodule

module mkXilinxIntDivUnsigned(XilinxIntDiv#(tagT)) provisos (
    Bits#(tagT, tagSz), Add#(tagSz, a__, 8)
);
`ifdef BSIM
    IntDivImport#(IntDivUnsignedUser) divIfc <- mkIntDivSim(True);
`else
    IntDivImport#(IntDivUnsignedUser) divIfc <- mkIntDivUnsignedImport;
`endif
    WaitAutoReset#(4) init <- mkWaitAutoReset;

    method Action req(
        Bit#(64) dividend, Bit#(64) divisor, tagT tag
    ) if(init.isReady);
        let user = IntDivUnsignedUser {
            divideZero: divisor == 0,
            dividend: dividend,
            tag: zeroExtend(pack(tag))
        };
        divIfc.enqDividend(dividend, user);
        divIfc.enqDivisor(divisor);
    endmethod

    method Action deqResp if(init.isReady);
        divIfc.deqResp;
    endmethod

    method respValid = divIfc.respValid && init.isReady;
    
    method Bit#(64) quotient if(init.isReady);
        let user = divIfc.respUser;
        Bit#(64) q;
        if(user.divideZero) begin
            q = maxBound;
        end
        else begin
            q = truncateLSB(divIfc.quotient_remainder);
        end
        return q;
    endmethod
    
    method Bit#(64) remainder if(init.isReady);
        let user = divIfc.respUser;
        Bit#(64) r;
        if(user.divideZero) begin
            r = user.dividend;
        end
        else begin
            r = truncate(divIfc.quotient_remainder);
        end
        return r;
    endmethod 

    method tagT respTag if(init.isReady);
        return unpack(truncate(divIfc.respUser.tag));
    endmethod
endmodule
