#include "MulDivTestIndication.h"
#include "MulDivTestRequest.h"
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <random>

const uint64_t most_negative = 0x8000000000000000ULL;

MulDivResp refResp(const MulDivReq &req) {
    MulDivResp resp;
    // mul
    __int128 a = req.mulSign == Unsigned ? __int128(uint64_t(req.a)) :
                                           __int128(int64_t(req.a));
    __int128 b = req.mulSign == Signed ? __int128(int64_t(req.b)) :
                                         __int128(uint64_t(req.b));
    __int128 prod = a * b;
    resp.productHi = uint64_t(prod >> 64);
    resp.productLo = uint64_t(prod);
    resp.mulTag = req.tag;
    // div
    if(req.divSigned) {
        if(req.a == most_negative && req.b == uint64_t(-1LL)) {
            resp.quotient = most_negative;
            resp.remainder = 0;
        } else if(req.b == 0) {
            resp.quotient = uint64_t(-1LL);
            resp.remainder = req.a;
        } else {
            resp.quotient = uint64_t(int64_t(req.a) / int64_t(req.b));
            resp.remainder = uint64_t(int64_t(req.a) % int64_t(req.b));
        }
    } else {
        if(req.b == 0) {
            resp.quotient = uint64_t(-1LL);
            resp.remainder = req.a;
        } else {
            resp.quotient = uint64_t(uint64_t(req.a) / uint64_t(req.b));
            resp.remainder = uint64_t(uint64_t(req.a) % uint64_t(req.b));
        }
    }
    resp.divTag = req.tag;

    return resp;
}

bool sameResp(const MulDivResp &x, const MulDivResp &y) {
    return (x.productHi == y.productHi &&
            x.productLo == y.productLo &&
            x.mulTag == y.mulTag &&
            x.quotient == y.quotient &&
            x.remainder == y.remainder &&
            x.divTag == y.divTag);
}

void printReq(const MulDivReq &r, FILE *fp = stderr) {
    fprintf(fp, "a %08llx, b %08llx, sign %d, tag %3d\n",
            (long long unsigned)(r.a), (long long unsigned)(r.b),
            int(r.mulSign), int(r.tag));
}

void printResp(const MulDivResp &r, FILE *fp = stderr) {
    fprintf(fp, "product %08llx %08llx, tag %3d, "
            "quotient %08llx, remainder %08llx, tag %3d\n",
            (long long unsigned)(r.productHi),
            (long long unsigned)(r.productLo),
            int(r.mulTag),
            (long long unsigned)(r.quotient),
            (long long unsigned)(r.remainder),
            int(r.divTag));
}

const int test_num = MAX_TEST_NUM;
MulDivReq all_req[test_num];

class MulDivTestIndication : public MulDivTestIndicationWrapper {
private:
    sem_t sem;
    int resp_id;

public:
    MulDivTestIndication(int id) : MulDivTestIndicationWrapper(id), resp_id(0) {
        sem_init(&sem, 0, 0);
    }

    virtual ~MulDivTestIndication() {
        sem_destroy(&sem);
    }

    virtual void resp(MulDivResp r) {
        MulDivResp ref = refResp(all_req[resp_id]);

        fprintf(stderr, "Test %d\n", resp_id);
        fprintf(stderr, "Req : ");
        printReq(all_req[resp_id]);
        fprintf(stderr, "Resp: ");
        printResp(r);
        fprintf(stderr, "Ref : ");
        printResp(ref);
        fprintf(stderr, "\n");

        if(!sameResp(r, ref)) {
            fprintf(stderr, "FAIL!!\n");
            exit(-1);
        }

        resp_id++;
        if(resp_id == test_num) {
            sem_post(&sem);
        }
    }

    void wait() {
        sem_wait(&sem);
    }
};

int main(int argc, char **argv) {
    MulDivTestIndication indication(IfcNames_MulDivTestIndicationH2S);
    MulDivTestRequestProxy reqProxy(IfcNames_MulDivTestRequestS2H);

    // first some corner case tests
    MulDivReq req;
    // overflow
    req.a = most_negative;
    req.b = uint64_t(-1LL);
    req.mulSign = Signed;
    req.divSigned = true;
    all_req[0] = req;
    // div by 0
    req.a = most_negative;
    req.b = 0;
    req.mulSign = Unsigned;
    req.divSigned = false;
    all_req[1] = req;
    // div by 0
    req.a = -200;
    req.b = 0;
    req.mulSign = SignedUnsigned;
    req.divSigned = true;
    all_req[2] = req;
    // div by 0
    req.a = 0;
    req.b = 0;
    req.mulSign = Signed;
    req.divSigned = false;
    all_req[3] = req;
    // div by 0
    req.a = 9;
    req.b = 0;
    req.mulSign = Unsigned;
    req.divSigned = true;
    all_req[4] = req;

    // remaining random reqs
    for(int i = 5; i < test_num; i++) {
        req.a = uint64_t(rand());
        req.b = uint64_t(rand());
        req.mulSign = MulSign(rand() % 3);
        req.divSigned = bool(rand() % 2);
        all_req[i] = req;
    }

    // fill in tags
    uint32_t tag_mask = (1 << USER_TAG_SIZE) - 1;
    for(uint32_t i = 0; i < test_num; i++) {
        all_req[i].tag = UserTag(i & tag_mask);
    }

    // send req to FPGA
    for(int i = 0; i < test_num; i++) {
        reqProxy.setTest(all_req[i], int(i == (test_num - 1)));
    }

    // wait done
    indication.wait();
    fprintf(stderr, "PASS!!\n");

    return 0;
}
