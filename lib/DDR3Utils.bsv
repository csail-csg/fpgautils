import Clocks::*;
import FIFO::*;
import FIFOF::*;
import Vector::*;
import GetPut::*;
import Connectable::*;
import RegFile::*;
import BRAMFIFO::*;
import DDR3Common::*;
import SyncFifo::*;

// simulation
module mkDDR3User_bsim(
    DDR3_1GB_User#(maxReadNum, delay)
) provisos (
    Alias#(readCntT, Bit#(TLog#(TAdd#(maxReadNum, 1)))), // 0 ~ maxReadNum
    Add#(1, a__, maxReadNum),
    Add#(1, b__, delay)
);
    Integer maxReadsInFlight = valueOf(maxReadNum);

    FIFO#(DDR3UserReq) reqQ <- mkFIFO;
    FIFO#(DDR3UserData) respQ <- mkSizedFIFO(maxReadsInFlight); // match FPGA impl, don't block on FIFO size
    Vector#(delay, FIFO#(DDR3UserData)) delayQ <- replicateM(mkFIFO);

    Reg#(readCntT) readCnt <- mkReg(0);
    PulseWire inc <- mkPulseWire;
    PulseWire dec <- mkPulseWire;

    RegFile#(DDR3UserAddr, DDR3UserData) mem <- mkRegFileFull;

    rule doWriteReq(reqQ.first.wrBE != 0);
        reqQ.deq;
        DDR3UserReq req = reqQ.first;
        Vector#(DDR3UserBESz, Bit#(8)) data = unpack(mem.sub(req.addr));
        Vector#(DDR3UserBESz, Bit#(8)) wrData = unpack(req.data);
        for(Integer i = 0; i < valueOf(DDR3UserBESz); i = i+1) begin
            if(req.wrBE[i] == 1) begin
                data[i] = wrData[i];
            end
        end
        mem.upd(req.addr, pack(data));
    endrule

    rule doReadReq(reqQ.first.wrBE == 0 && readCnt < fromInteger(maxReadsInFlight));
        reqQ.deq;
        DDR3UserReq req = reqQ.first;
        delayQ[0].enq(mem.sub(req.addr));
        inc.send; // inc read cnt
    endrule

    for(Integer i = 0; i < valueOf(delay) - 1; i = i+1) begin
        mkConnection(toGet(delayQ[i]), toPut(delayQ[i + 1]));
    end

    rule doSendResp;
        DDR3UserData resp <- toGet(delayQ[valueOf(delay) - 1]).get;
        respQ.enq(resp);
        dec.send; // dec read cnt
    endrule

    (* fire_when_enabled, no_implicit_conditions *)
    rule updateReadCnt;
        readCntT next = readCnt;
        if(inc) begin
            next = next + 1;
            if(readCnt >= fromInteger(maxReadsInFlight)) begin
                $fdisplay(stderr, "ERROR: %t DDR3User_bsim %m readCnt overflow: %d - 1",
                    $time, readCnt
                );
                $finish;
            end
        end
        if(dec) begin
            next = next - 1;
            if(readCnt == 0) begin
                $fdisplay(stderr, "ERROR: %t DDR3User_bsim %m readCnt underflow: %d - 1",
                    $time, readCnt
                );
                $finish;
            end
        end
        readCnt <= next;
    endrule

    //method Bool initDone = True;
    method Action req(DDR3UserReq r);
        reqQ.enq(r);
    endmethod
    method ActionValue#(DDR3UserData) rdResp;
        respQ.deq;
        return respQ.first;
    endmethod
    method ActionValue#(DDR3Err) err if(False);
        return ?;
    endmethod
endmodule


// Xilinx FPGA implementation
// Add flow ctrl based on the module provided by bluespec lib

// 2 transactions for each read/write req, used for 2:1 DDR3 controller (400MHz)
// This module should be clocked by Xilinx App clock
// the interface methods are in user (main design) clock domain
module mkDDR3User_2beats#(
    DDR3_1GB_App appIfc,
    Clock user_clk,
    Reset user_rst,
    DDR3_Controller_Config cfg
)(
    DDR3_1GB_User#(maxReadNum, simDelay)
) provisos (
    Mul#(2, DDR3AppDataSz, DDR3UserDataSz), // app data * 2 = user data = 512 bits
    Alias#(readCntT, Bit#(TLog#(TAdd#(maxReadNum, 1)))), // 0 ~ maxReadNum
    Add#(1, a__, maxReadNum)
);
    // sync req & resp Q
    SyncFIFOIfc#(DDR3UserReq) fRequest;
    SyncFIFOIfc#(DDR3UserData) fRespSync;
    //if(cfg.useBramSyncFifo) begin
    //    fRequest  <- mkSyncBRAMFIFOToCC(cfg.syncFifoSz, user_clk, user_rst);
    //    fRespSync <- mkSyncBRAMFIFOFromCC(cfg.syncFifoSz, user_clk, user_rst);
    //end
    //else begin
    //    fRequest  <- mkSyncFIFOToCC(cfg.syncFifoSz, user_clk, user_rst);
    //    fRespSync <- mkSyncFIFOFromCC(cfg.syncFifoSz, user_clk);
    //end
    Clock app_clk <- exposeCurrentClock;
    Reset app_rst <- exposeCurrentReset;
    if(cfg.useBramSyncFifo) begin
        fRequest  <- mkSyncBramFifo(cfg.syncFifoSz, user_clk, user_rst, app_clk, app_rst);
        fRespSync <- mkSyncBramFifo(cfg.syncFifoSz, app_clk, app_rst, user_clk, user_rst);
    end
    else begin
        fRequest  <- mkSyncFifo(cfg.syncFifoSz, user_clk, user_rst, app_clk, app_rst);
        fRespSync <- mkSyncFifo(cfg.syncFifoSz, app_clk, app_rst, user_clk, user_rst);
    end

    // resp buffer Q
    FIFOF#(DDR3AppData) fResponse; // 1 read resp == 2 fifo elements
    if(cfg.useBramRespBuffer) begin
        fResponse <- mkSizedBRAMFIFOF(2 * valueOf(maxReadNum));
    end
    else begin
        fResponse <- mkSizedFIFOF(2 * valueOf(maxReadNum));
    end

    // number of slots in fResponse reserved by reads
    Reg#(readCntT) pendReadCnt <- mkReg(0);
    PulseWire incPendRead <- mkPulseWire;
    PulseWire decPendRead <- mkPulseWire;
   
    // write data needs 2 cycles: should deq write req this cycle
    Reg#(Bool)         rDeqWriteReq   <- mkReg(False);

    // read data needs 2 cycles, data is first enq into fResponse
    // then assemble to 512bit user data from fResponse to fRespSync
    Reg#(Bool)         rEnqReadResp   <- mkReg(False); // should enq read resp this cycle
    Reg#(DDR3AppData)  rFirstResponse <- mkReg(0); // store first half (LSB) of the read resp
    
    // wires to drive Xilinx APP ifc
    PulseWire          pwAppEn        <- mkPulseWire;
    PulseWire          pwAppWdfWren   <- mkPulseWire;
    PulseWire          pwAppWdfEnd    <- mkPulseWire;
    
    Wire#(Bit#(3))     wAppCmd        <- mkDWire(0);
    Wire#(DDR3AppAddr) wAppAddr       <- mkDWire(0);
    Wire#(DDR3AppBE)   wAppWdfMask    <- mkDWire(maxBound);
    Wire#(DDR3AppData) wAppWdfData    <- mkDWire(0);
    
    Bool initialized      = appIfc.init_done;
    Bool ctrl_ready_req   = appIfc.app_rdy;
    Bool write_ready_req  = appIfc.app_wdf_rdy;
    Bool read_data_ready  = appIfc.app_rd_data_valid;

    // check error
    Reg#(Bool) dropResp <- mkReg(False);
    Reg#(Bool) readCntOverflow <- mkReg(False);
    Reg#(Bool) readCntUnderflow <- mkReg(False);
    //SyncFIFOIfc#(DDR3Err) fErr <- mkSyncFIFOFromCC(2, user_clk);
    SyncFIFOIfc#(DDR3Err) fErr <- mkSyncFifo(1, app_clk, app_rst, user_clk, user_rst);
    Reg#(Bool) errSent <- mkReg(False); // only send error once

    // app addr is for 8B, while user req addr is for 64B
    function DDR3AppAddr getAppAddr(DDR3UserAddr a) = {a, 3'b0};
    
    (* fire_when_enabled, no_implicit_conditions *)
    rule drive_enables;
        appIfc.app_en(pwAppEn);
        appIfc.app_wdf_wren(pwAppWdfWren);
        appIfc.app_wdf_end(pwAppWdfEnd);
    endrule
 
    (* fire_when_enabled, no_implicit_conditions *)
    rule drive_data_signals;
        appIfc.app_cmd(wAppCmd);
        appIfc.app_addr(wAppAddr);
        appIfc.app_wdf_data(wAppWdfData);
        appIfc.app_wdf_mask(wAppWdfMask);
    endrule
    
    // user write req: first cycle to send write cmd & LSB of write data
    (* fire_when_enabled *)
    rule process_write_request_first(
        initialized && fRequest.first.wrBE != 0 &&
        !rDeqWriteReq && ctrl_ready_req && write_ready_req
    );
   	    rDeqWriteReq <= True; // next cycle finish write req
   	    wAppCmd      <= 0;
   	    wAppAddr     <= getAppAddr(fRequest.first.addr);
   	    pwAppEn.send;
   	    wAppWdfData  <= truncate(fRequest.first.data);
   	    wAppWdfMask  <= ~truncate(fRequest.first.wrBE); // app mask = 1 means NOT write
   	    pwAppWdfWren.send;
    endrule
       
    // user write req: second cycle to send MSB of write data & deq user req
    (* fire_when_enabled *)
    rule process_write_request_second(
        initialized && fRequest.first.wrBE != 0 &&
        rDeqWriteReq && write_ready_req
    );
        // cmd already sent, no need here
 	    fRequest.deq; // user req done, deq
 	    rDeqWriteReq <= False; // reset bookkeeping
 	    wAppWdfData  <= truncateLSB(fRequest.first.data);
 	    wAppWdfMask  <= ~truncateLSB(fRequest.first.wrBE); // app mask = 1 means NOT write
 	    pwAppWdfWren.send;
        pwAppWdfEnd.send; // data end
    endrule
       
    // read req: ensure there is room in fResponse
    (* fire_when_enabled *)
    rule process_read_request(
        initialized && fRequest.first.wrBE == 0 && ctrl_ready_req &&
        pendReadCnt < fromInteger(valueOf(maxReadNum))
    );
 	    fRequest.deq;
 	    wAppCmd  <= 1;
 	    wAppAddr <= getAppAddr(fRequest.first.addr);
 	    pwAppEn.send;
        incPendRead.send; // incr pending read cnt
    endrule

    // get read resp from app ifc
    (* fire_when_enabled *)
    rule get_read_response(initialized && read_data_ready);
        fResponse.enq(appIfc.app_rd_data);
    endrule

    // check resp drop
    (* fire_when_enabled, no_implicit_conditions *)
    rule check_resp_drop(initialized && read_data_ready && !fResponse.notFull);
        dropResp <= True;
    endrule
      
    // assemble read resp
    (* fire_when_enabled *)
    rule assemble_read_response_first(!rEnqReadResp);
        fResponse.deq;
        rEnqReadResp <= True;
        rFirstResponse <= fResponse.first;
    endrule

    (* fire_when_enabled *)
    rule assemble_read_response_second(rEnqReadResp);
        fResponse.deq;
        rEnqReadResp <= False;
        fRespSync.enq({fResponse.first, rFirstResponse});
        // read resp done, decr pend read cnt
        decPendRead.send;
    endrule
 
    // update and check pendReadCnt
    (* fire_when_enabled, no_implicit_conditions *)
    rule update_pend_read_cnt;
        readCntT next = pendReadCnt;
        if(incPendRead) begin
            next = next + 1;
        end
        if(decPendRead) begin
            next = next - 1;
        end
        pendReadCnt <= next;
        // check error
        if(incPendRead && pendReadCnt >= fromInteger(valueOf(maxReadNum))) begin
            readCntOverflow <= True;
        end
        if(decPendRead && pendReadCnt == 0) begin
            readCntUnderflow <= True;
        end
    endrule

    // send error
    rule send_error(!errSent);
        if(dropResp) begin
            fErr.enq(DropResp);
            errSent <= True;
        end
        else if(readCntOverflow) begin
            fErr.enq(ReadCntOverflow);
            errSent <= True;
        end
        else if(readCntUnderflow) begin
            fErr.enq(ReadCntUnderflow);
            errSent <= True;
        end
    endrule

    //method initDone = initialized;
    
    method Action req(DDR3UserReq r);
        fRequest.enq(r);
    endmethod
   
    method ActionValue#(DDR3UserData) rdResp;
        fRespSync.deq;
        return fRespSync.first;
    endmethod

    method ActionValue#(DDR3Err) err;
        fErr.deq;
        return fErr.first;
    endmethod
endmodule

// 1 transaction for each read/write req, used for 4:1 DDR3 controller (800MHz)
// This module should be clocked by Xilinx App clock
// the interface methods are in user (main design) clock domain
//module mkDDR3User_1beat#(
//    DDR3_1GB_App appIfc,
//    Clock user_clk,
//    Reset user_rst
//)(
//    DDR3_1GB_User#(maxReadNum, simDelay)
//) provisos (
//    Add#(0, DDR3AppDataSz, DDR3UserDataSz), // app data = user data = 512 bits
//    Alias#(readCntT, Bit#(TLog#(TAdd#(maxReadNum, 1)))), // 0 ~ maxReadNum
//    Add#(1, a__, maxReadNum)
//);
//
//    Integer maxReadsInFlight = valueOf(maxReadNum);
//
//    // req & resp q
//    SyncFIFOIfc#(DDR3UserReq)  fRequest  <- mkSyncFIFOToCC(2, user_clk, user_rst);
//    FIFOF#(DDR3UserData)       fResponse <- mkSizedFIFOF(maxReadsInFlight);
//    SyncFIFOIfc#(DDR3UserData) fRespSync <- mkSyncFIFOFromCC(2, user_clk);
//
//    // number of slots in fResponse reserved by reads
//    Reg#(readCntT) pendReadCnt <- mkReg(0);
//    PulseWire incPendRead <- mkPulseWire;
//    PulseWire decPendRead <- mkPulseWire;
//   
//    // check error
//    Reg#(Bool) dropResp <- mkReg(False);
//    Reg#(Bool) readCntOverflow <- mkReg(False);
//    Reg#(Bool) readCntUnderflow <- mkReg(False);
//    SyncFIFOIfc#(DDR3Err) fErr <- mkSyncFIFOFromCC(2, user_clk);
//    Reg#(Bool) errSent <- mkReg(False); // only send error once
//
//    // wires to drive inputs to xilinx app ifc
//    PulseWire                  pwAppEn      <- mkPulseWire;
//    PulseWire                  pwAppWdfWren <- mkPulseWire;
//    PulseWire                  pwAppWdfEnd  <- mkPulseWire;
//    
//    Wire#(Bit#(3))             wAppCmd      <- mkDWire(0);
//    Wire#(Bit#(DDR3AppAddrSz)) wAppAddr     <- mkDWire(0);
//    Wire#(Bit#(DDR3AppBESz))   wAppWdfMask  <- mkDWire(maxBound);
//    Wire#(Bit#(DDR3AppDataSz)) wAppWdfData  <- mkDWire(0);
//    
//    Bool initialized     = appIfc.init_done;
//    Bool ctrl_ready_req  = appIfc.app_rdy;
//    Bool write_ready_req = appIfc.app_wdf_rdy;
//    Bool read_data_ready = appIfc.app_rd_data_valid;
//    
//    // drive signals
//    (* fire_when_enabled, no_implicit_conditions *)
//    rule drive_enables;
//        appIfc.app_en(pwAppEn);
//        appIfc.app_wdf_wren(pwAppWdfWren);
//        appIfc.app_wdf_end(pwAppWdfEnd);
//    endrule
//
//    (* fire_when_enabled, no_implicit_conditions *)
//    rule drive_data_signals;
//        appIfc.app_cmd(wAppCmd);
//        appIfc.app_addr(wAppAddr);
//        appIfc.app_wdf_data(wAppWdfData);
//        appIfc.app_wdf_mask(wAppWdfMask);
//    endrule
//    
//    // get write req
//    (* fire_when_enabled *)
//    rule process_write_request(initialized && (fRequest.first.wrBE != 0) && ctrl_ready_req && write_ready_req);
//        let request <- toGet(fRequest).get;
//        wAppCmd     <= 0;
//        wAppAddr    <= {request.addr, 3'b0}; // user addr is for 64B, app_addr is for 8B
//        wAppWdfData <= request.data;
//        wAppWdfMask <= ~request.wrBE; // app_wdf_mask = 1 means not write
//        pwAppEn.send;
//        pwAppWdfWren.send;
//        pwAppWdfEnd.send;
//    endrule
//    
//    // get read req
//    // cannot issue read when there is not enough space in resp fifo
//    (* fire_when_enabled *)
//    rule process_read_request(initialized && fRequest.first.wrBE == 0 && ctrl_ready_req && 
//                              pendReadCnt < fromInteger(maxReadsInFlight));
//        let request <- toGet(fRequest).get;
//        wAppCmd  <= 1;
//        wAppAddr <= {request.addr, 3'b0}; // user addr is for 64B, app_addr is for 8B
//        pwAppEn.send;
//        incPendRead.send; // incr read cnt
//    endrule
//    
//    // get read resp
//    (* fire_when_enabled *)
//    rule process_read_response(initialized && read_data_ready);
//        fResponse.enq(appIfc.app_rd_data);
//    endrule
//
//    // check resp drop
//    (* fire_when_enabled, no_implicit_conditions *)
//    rule check_drop_resp(initialized && read_data_ready && !fResponse.notFull);
//        dropResp <= True;
//    endrule
//
//    // sync read resp to user clock
//    (* fire_when_enabled *)
//    rule sync_read_resp(initialized); 
//        fResponse.deq;
//        fRespSync.enq(fResponse.first);
//        decPendRead.send; // decr read cnt
//    endrule
//
//    // update and check pendReadCnt
//    (* fire_when_enabled, no_implicit_conditions *)
//    rule update_pend_read_cnt;
//        readCntT next = pendReadCnt;
//        if(incPendRead) begin
//            next = next + 1;
//        end
//        if(decPendRead) begin
//            next = next - 1;
//        end
//        pendReadCnt <= next;
//        // check error
//        if(incPendRead && pendReadCnt >= fromInteger(maxReadsInFlight)) begin
//            readCntOverflow <= True;
//        end
//        if(decPendRead && pendReadCnt == 0) begin
//            readCntUnderflow <= True;
//        end
//    endrule
//
//    // send error
//    rule send_error(!errSent);
//        if(dropResp) begin
//            fErr.enq(DropResp);
//            errSent <= True;
//        end
//        else if(readCntOverflow) begin
//            fErr.enq(ReadCntOverflow);
//            errSent <= True;
//        end
//        else if(readCntUnderflow) begin
//            fErr.enq(ReadCntUnderflow);
//            errSent <= True;
//        end
//    endrule
//
//    method initDone = initialized;
//    
//    method Action req(DDR3UserReq r);
//        fRequest.enq(r);
//    endmethod
//   
//    method ActionValue#(DDR3UserData) rdResp;
//        fRespSync.deq;
//        return fRespSync.first;
//    endmethod
//
//    method ActionValue#(DDR3Err) err;
//        fErr.deq;
//        return fErr.first;
//    endmethod
//endmodule

