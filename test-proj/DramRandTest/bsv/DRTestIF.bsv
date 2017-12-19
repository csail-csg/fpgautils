
typedef `LOG_MAX_ADDR_NUM LogMaxAddrNum; // log max number of addr for testing
typedef Bit#(LogMaxAddrNum) TestAddrIdx;

// the number of tested addr may be smaller than 2^LogMaxAddrNum
// but this number is always power of 2

// total test num = test num specified by host + 2 * addr num
// 2 * addr num req consists of write init and read check for each addr

typedef enum {
    TestNum,
    DataSeed,
    BESeed,
    IdxSeed,
    SendStall, // stall ratio: 0 - 2 ^ `LOG_STALL_RATIO - 1
    RecvStall, // stall ratio
    Addr,
    Start
} SetupType deriving(Bits, Eq);

interface DRTestRequest;
    method Action setup(Bit#(64) data, SetupType t);
endinterface

interface DRTestIndication;
    method Action inited(TestAddrIdx mask);
    method Action done(Bit#(64) elapTime, Bit#(64) rdLatSum, Bit#(64) rdNum);
    method Action testErr(Bit#(64) rdNum);
    method Action dramErr(Bit#(4) e);
endinterface
