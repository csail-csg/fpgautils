import ClientServer::*;
import GetPut::*;
import FloatingPoint::*;
import Divide::*;
import SquareRoot::*;

import FpuTestIF::*;
import XilinxFpu::*;

interface FpuTest;
    method Action req(TestReq r);
    method ActionValue#(AllResults) resp;
endinterface

module mkFpuTest#(
    Server#(
        Tuple4#(Maybe#(Double), Double, Double, FpuRoundMode),
        Tuple2#(Double, FpuException)
    ) fmaIfc,
    Server#(
        Tuple3#(Double, Double, FpuRoundMode),
        Tuple2#(Double, FpuException)
    ) divIfc,
    Server#(
        Tuple2#(Double, FpuRoundMode),
        Tuple2#(Double, FpuException)
    ) sqrtIfc
)(FpuTest);

    Reg#(Bool) testing <- mkReg(False);
    Reg#(Bit#(8)) timer <- mkReg(0);
    Reg#(Maybe#(Result)) fmaRes <- mkReg(Invalid);
    Reg#(Maybe#(Result)) divRes <- mkReg(Invalid);
    Reg#(Maybe#(Result)) sqrtRes <- mkReg(Invalid);

    // xilinx IP only supports one rounding mode
    RoundMode rnd = Rnd_Nearest_Even;

    rule getFma(testing && !isValid(fmaRes));
        let {val, excep} <- fmaIfc.response.get;
        fmaRes <= Valid (Result {
            data: pack(val),
            exception: pack(excep),
            latency: timer
        });
    endrule

    rule getDiv(testing && !isValid(divRes));
        let {val, excep} <- divIfc.response.get;
        divRes <= Valid (Result {
            data: pack(val),
            exception: pack(excep),
            latency: timer
        });
    endrule

    rule getSqrt(testing && !isValid(sqrtRes));
        let {val, excep} <- sqrtIfc.response.get;
        sqrtRes <= Valid (Result {
            data: pack(val),
            exception: pack(excep),
            latency: timer
        });
    endrule

    rule incrTimer(testing);
        if(timer != maxBound) begin
            timer <= timer + 1;
        end
    endrule

    method Action req(TestReq r) if(!testing);
        testing <= True;
        timer <= 1; // we need to count this cycle
        fmaRes <= Invalid;
        divRes <= Invalid;
        sqrtRes <= Invalid;
        fmaIfc.request.put(tuple4(
            r.a_valid ? Valid (unpack(r.a_data)) : Invalid,
            unpack(r.b), unpack(r.c), rnd
        ));
        divIfc.request.put(tuple3(unpack(r.b), unpack(r.c), rnd));
        sqrtIfc.request.put(tuple2(unpack(r.c), rnd));
    endmethod

    method ActionValue#(AllResults) resp if(
        testing && isValid(fmaRes) && isValid(divRes) && isValid(sqrtRes)
    );
        testing <= False;
        return AllResults {
            fma: validValue(fmaRes),
            div_bc: validValue(divRes),
            sqrt_c: validValue(sqrtRes)
        };
    endmethod
endmodule

(* synthesize *)
module mkXilinxFpuTest(FpuTest);
    let fma <- mkXilinxFpFma;
    let div <- mkXilinxFpDiv;
    let sqrt <- mkXilinxFpSqrt;
    let m <- mkFpuTest(fma, div, sqrt);
    return m;
endmodule

(* synthesize *)
module mkBluespecFpuTest(FpuTest);
    let fma <- mkFloatingPointFusedMultiplyAccumulate;
    let intDiv <- mkDivider(1);
    let div <- mkFloatingPointDivider(intDiv);
    let intSqrt <- mkSquareRooter(1);
    let sqrt <- mkFloatingPointSquareRooter(intSqrt);
    let m <- mkFpuTest(fma, div, sqrt);
    return m;
endmodule
