import Axi4MasterSlave::*;
import AxiBits::*;

// AWS physical (axi) interface
typedef 64 AWSDramAxiAddrSz;
typedef 16 AWSDramAxiIdSz;
typedef 512 AWSDramAxiDataSz;
typedef TDiv#(AWSDramAxiDataSz, 8) AWSDramAxiBESz;
typedef AxiMasterBits#(
    AWSDramAxiAddrSz,
    AWSDramAxiDataSz,
    AWSDramAxiIdSz,
    Empty
) AWSDramPins;

// AWS user interface: 16GB DRAM, access with 64B aligned
typedef enum {AddrOverflow} AWSDramUserErr;
typedef DramUser#(
    maxReadNum,
    maxWriteNum,
    AWSDramUserErr
) AWSDramUser#(numeric type maxReadNum, numeric type maxWriteNum);

// AWS full interface
typedef DramFull#(
    maxReadNum,
    maxWriteNum,
    AWSDramUserErr,
`ifdef BSIM
    Empty
`else
    AWSDramPins
`endif
) AWSDramFull#(numeric type maxReadNum, numeric type maxWriteNum);
