import BRAM::*;
import DramCommon::*;
import DRTestIF::*;
import DefaultValue::*;

interface AddrBram;
    method Action req(Bool isWr, TestAddrIdx idx, DramUserAddr a);
    method ActionValue#(DramUserAddr) resp; // only for read
endinterface

(* synthesize *)
module mkAddrBram(AddrBram);
    BRAM1Port#(TestAddrIdx, DramUserAddr) bram <- mkBRAM1Server(defaultValue);

    method Action req(Bool isWr, TestAddrIdx idx, DramUserAddr a);
        bram.portA.request.put(BRAMRequest {
            write: isWr,
            responseOnWrite: False,
            address: idx,
            datain: a
        });
    endmethod

    method ActionValue#(DramUserAddr) resp;
        let r <- bram.portA.response.get;
        return r;
    endmethod
endmodule

interface DataBram;
    method Action req(TestAddrIdx idx, DramUserBE wrBE, DramUserData data);
    method ActionValue#(DramUserData) resp; // only for read
endinterface

(* synthesize *)
module mkDataBram(DataBram);
    BRAM1PortBE#(TestAddrIdx, DramUserData, DramUserBESz) bram <- mkBRAM1ServerBE(defaultValue);

    method Action req(TestAddrIdx idx, DramUserBE wrBE, DramUserData data);
        bram.portA.request.put(BRAMRequestBE {
            writeen: wrBE,
            responseOnWrite: False,
            address: idx,
            datain: data
        });
    endmethod

    method ActionValue#(DramUserData) resp;
        let r <- bram.portA.response.get;
        return r;
    endmethod
endmodule
