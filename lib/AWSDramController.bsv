import Axi4MasterSlave::*;
import AxiBits::*;

import DramUserCommon::*;
import AWSDramCommon::*;

// The controller runs at DRAM clock domain.

typedef 28 AWSDramUserAddrSz;
typedef Bit#(AWSDramUserAddrSz) AWSDramUserAddr;

typedef Axi4ReadRequest#(AWSDramAxiAddrSz, AWSDramAxiIdSz) AWSDramAxiReadReq;
typedef Axi4ReadResponse#(AWSDramAxiDataSz, AWSDramAxiIdSz) AWSDramAxiReadResp;
typedef Axi4WriteRequest#(

module mkAWSDramController(AWSDramFull#(maxReadNum, maxWriteNum));
endmodule
