
// Copyright (c) 2017 Massachusetts Institute of Technology
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


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
    method Action done(Bool pass, Bit#(64) elapTime, Bit#(64) rdLatSum, Bit#(64) rdNum);
    method Action testErr(Bit#(64) rdNum);
    method Action dramErr(Bit#(4) e);
endinterface
