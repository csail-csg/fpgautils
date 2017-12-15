
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

#include "SyncTestIndication.h"
#include "SyncTestRequest.h"
#include "GeneratedTypes.h"
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>

class SyncTestIndication;
SyncTestIndication *testInd = 0;
SyncTestRequestProxy *testReq = 0;

class SyncTestIndication : public SyncTestIndicationWrapper {
private:
    sem_t sem;
    long long unsigned test_num;
    TestMode mode;
    int fifo_num; // number of fifos to finish test

public:
    SyncTestIndication(int id, long long unsigned n_test, TestMode m) :
        SyncTestIndicationWrapper(id), 
        test_num(n_test),
        mode(m),
        fifo_num(LOG_MAX_FIFO_SZ + 1) // macro defined in makefile
    {
        sem_init(&sem, 0, 0);
    }

    virtual ~SyncTestIndication() {
        sem_destroy(&sem);
    }

    virtual void done(uint8_t logFifoSz, uint64_t totalTime) {
        fprintf(stderr, "INFO: FIFO size %d done: total %llu cycles, ",
                1 << logFifoSz, (long long unsigned)totalTime);
        // ge throughput or latency
        if(mode == Throughput) {
            double throughput = double(test_num) / double(totalTime);
            fprintf(stderr, "throughput %f data/cycle\n", throughput);
        }
        else {
            double lat = double(totalTime) / double(test_num);
            fprintf(stderr, "latency %f cycles\n", lat);
        }
        fifo_num--;
        if(fifo_num == 0) {
            sem_post(&sem);
        }
    }

    virtual void err(uint8_t logFifoSz, uint64_t recvNum) {
        fprintf(stderr, "ERROR: FIFO size %d err at %llu\n",
                1 << logFifoSz, (long long unsigned)recvNum);
        exit(-1);
    }

    void waitDone() {
        sem_wait(&sem);
    }
};

void usage(char *prog) {
    fprintf(stderr, "Usage: %s TEST_NUM MODE DELAY\n", prog);
    fprintf(stderr, "TEST_NUM > 0, MODE = Throughput or Latency\n");
}

int main(int argc, char *argv[]) {
    if(argc != 4) {
        usage(argv[0]);
        return 0;
    }
    long long unsigned test_num = std::stoull(argv[1]);
    if(test_num == 0) {
        usage(argv[0]);
        return 0;
    }
    TestMode mode = Throughput;
    if(strcmp(argv[2], "Throughput") == 0) {
        mode = Throughput;
    }
    else if(strcmp(argv[2], "Latency") == 0) { 
        mode = Latency;
    }
    int fast_delay = atoi(argv[3]);

    testInd = new SyncTestIndication(IfcNames_SyncTestIndicationH2S, test_num, mode);
    testReq = new SyncTestRequestProxy(IfcNames_SyncTestRequestS2H);

    fprintf(stderr, "INFO: start: slow clk %d ns, fast clk %d ns, mode %s, num %llu, delay %d\n",
            USER_CLK_PERIOD, MainClockPeriod, argv[2], test_num, fast_delay);
    testReq->start(test_num, mode, fast_delay);
    testInd->waitDone();

    fprintf(stderr, "INFO: all done\n");

    return 0;
}
