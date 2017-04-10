import Clocks::*;

interface ResetGuard;
    method Bool isReady;
endinterface

import "BVI" reset_guard =
module mkResetGuard(ResetGuard);
    default_clock clk(CLK);
    default_reset rst(RST);

    method IS_READY isReady();

    schedule (isReady) CF (isReady);
endmodule
