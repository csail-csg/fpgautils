import AWSDramCommon::*;
import AWSDramController::*;

typedef 16 AWSDramMaxReadNum;
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
    let m <- mkAWSDramController(dramAxiClk, dramAxiRst);
    return m;
endmodule
