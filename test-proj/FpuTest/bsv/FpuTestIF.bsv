typedef struct {
    Bool a_valid;
    Bit#(64) a_data;
    Bit#(64) b;
    Bit#(64) c;
} TestReq deriving(Bits, Eq, FShow);

interface FpuTestRequest;
    method Action req(TestReq r);
endinterface

typedef struct {
    Bit#(64) data;
    Bit#(5) exception;
    Bit#(8) latency;
} Result deriving(Bits, Eq, FShow);

typedef struct {
    Result fma; // a + b * c
    Result div_bc; // b / c
    Result sqrt_c; // sqrt(c)
} AllResults deriving(Bits, Eq, FShow);

interface FpuTestIndication;
    method Action resp(AllResults xilinx, AllResults bluespec);
endinterface
