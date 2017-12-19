import AWSDramCommon::*;
import AWSDramController::*;

typedef 128 AWSDramMaxReadNum;
typedef 16 AWSDramMaxWriteNum;
typedef 10 AWSDramSimDelay;

typedef AWSDramUser#(
    AWSDramMaxReadNum,
    AWSDramMaxWriteNum,
    AWSDramSimDelay
) AWSDramUserWrapper;

typedef AWSDramFull#(
    AWSDramMaxReadNum,
    AWSDramMaxWriteNum,
    AWSDramSimDelay
) AWSDramFullWrapper;

(* synthesize *)
module mkAWSDramWrapper#(Clock dramAxiClk, Reset dramAxiRst)(AWSDramFullWrapper);
    //let m <- mkAWSDramController(dramAxiClk, dramAxiRst, True);
    let m <- mkAWSDramBlockController(dramAxiClk, dramAxiRst);
    return m;
endmodule
