`include "ConnectalProjectConfig.bsv"

typedef `USER_TAG_SIZE UserTagSz;
typedef Bit#(UserTagSz) UserTag;

typedef enum {
    Signed,
    Unsigned,
    SignedUnsigned
} MulSign deriving(Bits, Eq, FShow);

typedef struct {
    Bit#(64) a;
    Bit#(64) b;
    MulSign sign;
    UserTag tag;
} MulDivReq deriving(Bits, Eq, FShow);

typedef struct {
    Bit#(64) productHi;
    Bit#(64) productLo;
    UserTag mulTag;
    Bit#(64) quotientSigned;
    Bit#(64) remainderSigned;
    UserTag divSignedTag;
    Bit#(64) quotientUnsigned;
    Bit#(64) remainderUnsigned;
    UserTag divUnsignedTag;
} MulDivResp deriving(Bits, Eq, FShow);

interface MulDivTestRequest;
    method Action setTest(MulDivReq r, Bool last);
endinterface

interface MulDivTestIndication;
    method Action resp(MulDivResp r);
endinterface
