
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

#include "GeneratedTypes.h"
#include "DRTestRequest.h"
#include "DRTestIndication.h"
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string>

class DRTestIndication;
DRTestIndication *testInd = 0;
DRTestRequestProxy *testReq = 0;


class DRTestIndication : public DRTestIndicationWrapper {
private:
    sem_t sem;
    unsigned int addr_num;
    long long unsigned total_test_num; // including init data & check

public:
    DRTestIndication(int id, int n_addr, long long unsigned n_test) :
        DRTestIndicationWrapper(id),
        addr_num(n_addr),
        total_test_num(n_test + 2 * n_addr)
    {
        sem_init(&sem, 0, 0);
    }

    virtual ~DRTestIndication() {
        sem_destroy(&sem);
    }

    virtual void inited(TestAddrIdx mask) {
        fprintf(stderr, "INFO: initialized, addr idx mask = %x\n", (unsigned)mask);
        if(unsigned(mask) != addr_num - 1) {
            fprintf(stderr, "ERROR: mask wrong, should be %d\n", addr_num - 1);
            exit(-1);
        }
    }

    virtual void done(int pass, uint64_t elapTime, uint64_t rdLatSum, uint64_t rdNum) {
        double tp =  double(total_test_num) / double(elapTime);
        double lat = double(rdLatSum) / double(rdNum);
        fprintf(stderr, "INFO: done: %s, "
                "elapTime %llu, rdLatSum %llu, rdNum %llu, "
                "total test num %llu, throughput %f data/cycle, "
                "latency %f cycles\n",
                pass ? "PASS" : "FAIL",
                (long long unsigned)elapTime, (long long unsigned)rdLatSum,
                (long long unsigned)rdNum, total_test_num, tp, lat);
        sem_post(&sem);
    }

    virtual void testErr(uint64_t rdNum) {
        fprintf(stderr, "ERROR: test err at read %llu\n", (long long unsigned)rdNum);
        //exit(-1);
    }

    virtual void dramErr(uint8_t e) {
        fprintf(stderr, "ERROR: dram err %d\n", (int)e);
        //exit(-1);
    }

    void waitDone() {
        sem_wait(&sem);
    }
};

void usage(char *prog) {
    fprintf(stderr, "Usage: %s LOG_ADDR_NUM TEST_NUM SEND_STALL RECV_STALL\n", prog);
}

unsigned int getSeed() {
    while(1) {
        int r = rand();
        if(r != 0) {
            return r;
        }
    }
}

bool isBadAddr(unsigned int exist_addr, unsigned new_addr) {
    return exist_addr == new_addr;
    // alternative: not same row+bank
    //return (exist_addr >> 7) == (new_addr >> 7);
}

int main(int argc, char *argv[]) {
    if(argc != 5) {
        usage(argv[0]);
        return 0;
    }
    int log_addr_num = atoi(argv[1]);
    if(log_addr_num < 0 || log_addr_num > LOG_MAX_ADDR_NUM) {
        fprintf(stderr, "LOG_ADDR_NUM must be in [0, %d]\n", LOG_MAX_ADDR_NUM);
        return 0;
    }
    int addr_num = 1 << log_addr_num;

    long long unsigned test_num = std::stoull(argv[2]);
    if(test_num == 0) {
        fprintf(stderr, "test num must > 0\n");
        return 0;
    }

    const int max_stall = (1 << LOG_STALL_RATIO) - 1;
    int send_stall = atoi(argv[3]);
    if(send_stall < 0 || send_stall > max_stall) {
        fprintf(stderr, "send_stall must be in [0, %d]\n", max_stall);
        return 0;
    }
    int recv_stall = atoi(argv[4]);
    if(recv_stall < 0 || recv_stall > max_stall) {
        fprintf(stderr, "recv_stall must be in [0, %d]\n", max_stall);
        return 0;
    }

    // init randomizer
    srand(time(0));

    // get random seeds
    unsigned int data_seed = getSeed();
    unsigned int be_seed = getSeed();
    unsigned int idx_seed = getSeed();

    fprintf(stderr, "INFO: addr num %d, test num %llu, data seed %x, be seed %x, idx seed %x, send stall %d/%d, recv stall %d/%d\n",
            addr_num, test_num, data_seed, be_seed, idx_seed, send_stall, max_stall + 1, recv_stall, max_stall + 1);

    // get addr
    unsigned int *addr = new unsigned int[addr_num];
    for(int i = 0; i < addr_num; i++) {
        while(1) {
            addr[i] = rand() & 0x00FFFFFF; // 24 bit addr
            bool bad_addr = false;
            for(int j = 0; j < i; j++) {
                if(isBadAddr(addr[j], addr[i])) {
                    bad_addr = true;
                    break;
                }
            }
            if(!bad_addr) {
                break;
            }
        }
    }
    // write the addr to log
    FILE *fp_addr = fopen("addr.txt", "wt");
    for(int i = 0; i < addr_num; i++) {
        fprintf(fp_addr, "%06x\n", addr[i]);
    }
    fclose(fp_addr);

    // cearte indication & req objects
    testInd = new DRTestIndication(IfcNames_DRTestIndicationH2S, addr_num, test_num);
    testReq = new DRTestRequestProxy(IfcNames_DRTestRequestS2H);

    // setup HW
    testReq->setup(test_num, TestNum);
    testReq->setup(data_seed, DataSeed);
    testReq->setup(be_seed, BESeed);
    testReq->setup(idx_seed, IdxSeed);
    testReq->setup(send_stall, SendStall);
    testReq->setup(recv_stall, RecvStall);
    for(int i = 0; i < addr_num; i++) {
        testReq->setup(addr[i], Addr);
    }
    testReq->setup(0, Start);

    fprintf(stderr, "INFO: start waiting...\n");
    testInd->waitDone();
    fprintf(stderr, "INFO: all done\n");

    return 0;
}
