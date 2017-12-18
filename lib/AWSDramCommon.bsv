import Axi4MasterSlave::*;
import AxiBits::*;

import DramCommon::*;

// AWS physical (axi) interface
typedef 64 AWSDramAxiAddrSz;
typedef 16 AWSDramAxiIdSz;
typedef 512 AWSDramAxiDataSz;
typedef TDiv#(AWSDramAxiDataSz, 8) AWSDramAxiBESz;
typedef Bit#(AWSDramAxiAddrSz) AWSDramAxiAddr;
typedef Bit#(AWSDramAxiIdSz) AWSDramAxiId;
typedef Bit#(AWSDramAxiDataSz) AWSDramAxiData;
typedef Bit#(AWSDramAxiBESz) AWSDramAxiBE;

interface AWSDramPins;
    (* always_enabled, always_ready, prefix = "" *)
    interface AxiMasterBits#(
        AWSDramAxiAddrSz,
        AWSDramAxiDataSz,
        AWSDramAxiIdSz,
        Empty
    ) axiMaster;
endinterface

// AWS user interface: 16GB DRAM, access with 64B aligned
typedef enum {AddrOverflow} AWSDramErr deriving(Bits, Eq, FShow);

typedef DramUser#(
    maxReadNum,
    maxWriteNum,
    simDelay,
    AWSDramErr
) AWSDramUser#(
    numeric type maxReadNum,
    numeric type maxWriteNum,
    numeric type simDelay
);

// AWS full interface
typedef DramFull#(
    maxReadNum,
    maxWriteNum,
    simDelay,
    AWSDramErr,
`ifdef BSIM
    Empty
`else
    AWSDramPins
`endif
) AWSDramFull#(
    numeric type maxReadNum,
    numeric type maxWriteNum,
    numeric type simDelay
);
