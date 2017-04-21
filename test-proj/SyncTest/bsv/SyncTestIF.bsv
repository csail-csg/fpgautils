
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

// test a loop back for a pair of sync FIFOs:
// current clock -> fast clock (some delay to adjust bandwidth) -> current clock
// we test with different FIFO depth

typedef enum {
    Throughput,
    Latency
} TestMode deriving(Bits, Eq);

interface SyncTestRequest;
    method Action start(Bit#(64) n, TestMode mode, Bit#(8) fastDelay);
endinterface

interface SyncTestIndication;
    method Action done(Bit#(8) logFifoSz, Bit#(64) totalTime);
    method Action err(Bit#(8) logFifoSz, Bit#(64) recvNum);
endinterface
