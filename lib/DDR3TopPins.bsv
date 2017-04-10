import DDR3Common::*;

export DDR3Common::*;
export DDR3TopPins(..);

interface DDR3TopPins;
    // XXX prefix DDR3 appears in XDC, don't change!
    (* prefix = "DDR3" *)
    interface DDR3_1GB_Pins ddr3;
endinterface
