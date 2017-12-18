import Assert::*;

// User interface:
// all DRAM use 64B data block
// present user with 64-bit address space, but addr should be in terms of 64B
typedef 512 DramUserDataSz;
typedef TDiv#(DramUserDataSz, 8) DramUserBESz;
typedef 58 DramUserAddrSz;

typedef Bit#(DramUserDataSz) DramUserData;
typedef Bit#(DramUserBESz) DramUserBE;
typedef Bit#(DramUserAddrSz) DramUserAddr;

typedef struct { // read/write req
    DramUserAddr addr;
    DramUserData data;
    DramUserBE wrBE; // all 0 means read,
    // otherwise wrBE[i]=1 means to write byte i
} DramUserReq deriving(Bits, Eq, FShow);

interface DramUser#(
    // maximum number of in-flight requests (not always used)
    numeric type maxReadNum,
    numeric type maxWriteNum,
    // simulation delay (fully pipelined)
    numeric type simDelay,
    // error of dram controller
    type errT
);
    method Action req(DramUserReq r);
    method ActionValue#(DramUserData) rdResp; // only read has resp
    method ActionValue#(errT) err;
endinterface

// Full interface
interface DramFull#(
    numeric type maxReadNum,
    numeric type maxWriteNum,
    numeric type simDelay,
    type errT,
    // pin type
    type pinT
);
    interface DramUser#(maxReadNum, maxWriteNum, simDelay, errT) user;
    interface pinT pins;
endinterface

`ifdef BSIM
function Action doAssert(Bool b, String s) = action if(!b) $fdisplay(stderr, "\n%m: ASSERT FAIL!!"); dynamicAssert(b, s); endaction;
`else
function Action doAssert(Bool b, String s) = noAction;
`endif
