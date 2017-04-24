
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

#include "DSTestIndication.h"
#include "DSTestRequest.h"
#include "GeneratedTypes.h"
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>

class DSTestIndication;
DSTestIndication *testInd = 0;
DSTestRequestProxy *testReq = 0;

const char *ddr3_err_str[] = {
    "DropResp",
    "ReadCntOverflow",
    "ReadCntUnderflow"
};

class DSTestIndication : public DSTestIndicationWrapper {
private:
    sem_t sem;
    int test_num;
    int last_done_id;
    const uint64_t req_num;
    const uint64_t req_bytes;
    const uint32_t cycle_time;

public:
    DSTestIndication(int id) : 
        DSTestIndicationWrapper(id), 
        test_num(-1), 
        last_done_id(-1),
        req_num(1ULL << 24), // 24bit addr x 64B data
        req_bytes(1ULL << 30), // 1GB data
        cycle_time(USER_CLK_PERIOD) // cycle time in ns
    {
        sem_init(&sem, 0, 0);
    }

    virtual ~DSTestIndication() {
        sem_destroy(&sem);
    }

    virtual void done(uint32_t testId, uint64_t wrTime, uint64_t rdTime, uint64_t rdLatSum) {
        if(int(testId) != (last_done_id + 1)) {
            fprintf(stderr, "ERROR: expected done test id = %d, recv done id = %d\n",
                    last_done_id + 1, (int)testId);
            exit(-1);
        }
        // throughput
        double wr_tp = double(req_bytes) / double(wrTime * cycle_time);
        double rd_tp = double(req_bytes) / double(rdTime * cycle_time);
        // latency
        double rd_lat = double(rdLatSum) / double(req_num);
        fprintf(stderr, "INFO: done test %d: wrTime %llu, rdTime %llu, rdLatSum %llu\n", (int)testId, 
                (long long unsigned)wrTime, (long long unsigned)rdTime, (long long unsigned)rdLatSum);
        fprintf(stderr, "      wr throughput: %f GB/s\n", wr_tp);
        fprintf(stderr, "      rd throughput: %f GB/s\n", rd_tp);
        fprintf(stderr, "      rd latency: %f cycles * %d ns\n", rd_lat, (int)cycle_time);
        // change state
        last_done_id++;
        if(last_done_id == test_num - 1) {
            sem_post(&sem);
        }
    }

    virtual void readErr(uint32_t testId, uint32_t rdAddr) {
        fprintf(stderr, "ERROR: test %d read %x\n", int(testId), (int)rdAddr);
        exit(-1);
    }

    virtual void dramErr(uint8_t e) {
        //fprintf(stderr, "ERROR: dram %s\n", e < 3 ? ddr3_err_str[e] : "unknown err");
        fprintf(stderr, "ERROR: dram %d\n", (int)e);
        exit(-1);
    }

    virtual void dramStatus(int init) {
        fprintf(stderr, "INFO: dram status %d\n", init);
    }

    void setTestNum(int num) {
        test_num = num;
    }

    void waitDone() {
        sem_wait(&sem);
    }
};

void usage(const char *prog) {
    fprintf(stderr, "Usage: %s TEST_NUM\n", prog);
}

int main(int argc, char *argv[]) {
    if(argc != 2) {
        usage(argv[0]);
        return 0;
    }

    int test_num = atoi(argv[1]);
    if(test_num <= 0) {
        usage(argv[0]);
        return 0;
    }

    fprintf(stderr, "INFO: test num = %d\n", test_num);

    testInd = new DSTestIndication(IfcNames_DSTestIndicationH2S);
    testReq = new DSTestRequestProxy(IfcNames_DSTestRequestS2H);
    // set test num
    testInd->setTestNum(test_num);
    // start test & wait
    testReq->start(test_num);
    fprintf(stderr, "INFO: waiting...\n");
    testInd->waitDone();
    fprintf(stderr, "INFO: all done\n");

    return 0;
}
