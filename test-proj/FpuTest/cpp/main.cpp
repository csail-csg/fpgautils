
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

#include "FpuTestIndication.h"
#include "FpuTestRequest.h"
#include "GeneratedTypes.h"
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <random>

TestReq curReq; // req sent to FPGA

// pack & unpack double
uint64_t inline packDouble(const double fp) {
    uint64_t bin = 0;
    memcpy(&bin, &fp, sizeof(double));
    return bin;
}
double inline unpackDouble(const uint64_t bin) {
    double fp = 0;
    memcpy(&fp, &bin, sizeof(double));
    return fp;
}

// get results in x86
void hostFpu(Result &result) {
}

class FpuTestIndication : public FpuTestIndicationWrapper {
private:
    sem_t sem;

public:
    FpuTestIndication(int id) : FpuTestIndicationWrapper(id) {
        sem_init(&sem, 0, 0);
    }

    virtual ~FpuTestIndication() {
        sem_destroy(&sem);
    }

    virtual void resp (const AllResults xilinx, const AllResults bluespec) {
        // convert req to double values
        double a = 0;
        if(curReq.a_valid) {
            a = unpackDouble(curReq.a_data);
        }
        double b = unpackDouble(curReq.b);
        double c = unpackDouble(curReq.c);
        printf("a = %f, b = %f, c = %f\n", a, b, c);

        // compute in host
        double fma_host = a + b * c;
        double div_host = b / c;
        double sqrt_host = sqrt(c);

        // get xilinx results
        double fma_xilinx = unpackDouble(xilinx.fma.data);
        double div_xilinx = unpackDouble(xilinx.div_bc.data);
        double sqrt_xilinx = unpackDouble(xilinx.sqrt_c.data);

        // get bluespec results
        double fma_bluespec = unpackDouble(bluespec.fma.data);
        double div_bluespec = unpackDouble(bluespec.div_bc.data);
        double sqrt_bluespec = unpackDouble(bluespec.sqrt_c.data);

        // print results
        printf("fma (a + b * c):\n"
               "  host     val %f\n"
               "  xilinx   val %f excep %d lat %d\n"
               "  bluespec val %f excep %d lat %d\n",
               fma_host,
               fma_xilinx, xilinx.fma.exception, xilinx.fma.latency,
               fma_bluespec, bluespec.fma.exception, bluespec.fma.latency);
        printf("div (b / c):\n"
               "  host     val %f\n"
               "  xilinx   val %f excep %d lat %d\n"
               "  bluespec val %f excep %d lat %d\n",
               div_host,
               div_xilinx, xilinx.div_bc.exception, xilinx.div_bc.latency,
               div_bluespec, bluespec.div_bc.exception, bluespec.div_bc.latency);
        printf("sqrt (c ^ 0.5):\n"
               "  host     val %f\n"
               "  xilinx   val %f excep %d lat %d\n"
               "  bluespec val %f excep %d lat %d\n",
               sqrt_host,
               sqrt_xilinx, xilinx.sqrt_c.exception, xilinx.sqrt_c.latency,
               sqrt_bluespec, bluespec.sqrt_c.exception, bluespec.sqrt_c.latency);

        sem_post(&sem);
    }

    void wait() {
        sem_wait(&sem);
    }
};

void usage(const char *prog) {
    fprintf(stderr, "Usage: %s TEST_NUM\n", prog);
}

int main(int argc, char **argv) {
    if(argc != 2) {
        usage(argv[0]);
        return 0;
    }

    int test_num = atoi(argv[1]);
    if(test_num <= 0) {
        usage(argv[0]);
        return 0;
    }

    FpuTestIndication testInd(IfcNames_FpuTestIndicationH2S);
    FpuTestRequestProxy testReq(IfcNames_FpuTestRequestS2H);

    // start test
    std::normal_distribution<double> norm;
    std::default_random_engine gen;
    for(int i = 0; i < test_num; i++) {
        // randomize input data
        double a = norm(gen);
        double b = norm(gen);
        double c = norm(gen);
        
        // create test req
        curReq.a_valid = 1;
        curReq.a_data = packDouble(a);
        curReq.b = packDouble(b);
        curReq.c = packDouble(c);
        printf("Test %d: a %d %llx (%f), b %llx (%f), c %llx (%f)\n",
               i, curReq.a_valid, (long long unsigned)curReq.a_data, a,
               (long long unsigned)curReq.b, b,
               (long long unsigned)curReq.c, c);

        // send to FPGA and wait
        testReq.req(curReq);
        testInd.wait();

        printf("\n");

        // redo the test with invalid a
        curReq.a_valid = 0;
        printf("Test %d alt: a %d %llx (%f), b %llx (%f), c %llx (%f)\n",
               i, curReq.a_valid, (long long unsigned)curReq.a_data, a,
               (long long unsigned)curReq.b, b,
               (long long unsigned)curReq.c, c);
        testReq.req(curReq);
        testInd.wait();

        printf("\n");
    }

    return 0;
}
