import Clocks::*;
import FIFOF::*;
import Assert::*;
import ConnectalBramFifo::*;
import BRAMFIFO::*;
import XilinxSyncFifo::*;
import ResetGuard::*;

export mkSyncFifo;
export mkSyncBramFifo;

// sync fifo type selec macros: USE_CONNECTAL_BRAM_SYNC_FIFO, USE_BSV_BRAM_SYNC_FIFO, USE_XILINX_SYNC_FIFO

// we also guard the sync fifo from enq/deq before the reset

module mkSyncFifo#(
    Integer depth, Clock srcClk, Reset srcRst, Clock dstClk, Reset dstRst
)(SyncFIFOIfc#(t)) provisos(
    Bits#(t, tW),
    NumAlias#(w, TMax#(1, tW)) // some sync fifo doesn't support 0-bit data
);
`ifdef USE_CONNECTAL_BRAM_SYNC_FIFO
    staticAssert(depth <= 512, "depth of FIFO18 is 512");
    FIFOF#(Bit#(w)) q <- mkDualClockBramFIFOF(srcClk, srcRst, dstClk, dstRst);

`elsif USE_BSV_BRAM_SYNC_FIFO
    SyncFIFOIfc#(Bit#(w)) q <- mkSyncBRAMFIFO(depth, srcClk, srcRst, dstClk, dstRst);

`elsif USE_XILINX_SYNC_FIFO
    staticAssert(depth <= 16, "depth of xilinx lut ram FIFO is 16");
    SyncFIFOIfc#(Bit#(w)) q <- mkXilinxSyncFifo(srcClk, srcRst, dstClk);

`else
    SyncFIFOIfc#(Bit#(w)) q <- mkSyncFIFO(depth, srcClk, srcRst, dstClk);

`endif

    // guard sync fifo operations
    ResetGuard srcGuard <- mkResetGuard(clocked_by srcClk, reset_by srcRst);
    ResetGuard dstGuard <- mkResetGuard(clocked_by dstClk, reset_by dstRst);

    method notFull = q.notFull && srcGuard.isReady;
    method Action enq(t x) if(srcGuard.isReady);
        q.enq(zeroExtend(pack(x)));
    endmethod

    method notEmpty = q.notEmpty && dstGuard.isReady;
    method t first if(dstGuard.isReady);
        return unpack(truncate(q.first));
    endmethod
    method Action deq if(dstGuard.isReady);
        q.deq;
    endmethod
endmodule

module mkSyncBramFifo#(
    Integer depth, Clock srcClk, Reset srcRst, Clock dstClk, Reset dstRst
)(SyncFIFOIfc#(t)) provisos(
    Bits#(t, tW),
    NumAlias#(w, TMax#(1, tW)) // some sync fifo doesn't support 0-bit data
);
`ifdef USE_CONNECTAL_BRAM_SYNC_FIFO
    staticAssert(depth <= 512, "depth of FIFO18 is 512");
    FIFOF#(Bit#(w)) q <- mkDualClockBramFIFOF(srcClk, srcRst, dstClk, dstRst);

`elsif USE_XILINX_SYNC_FIFO
    staticAssert(depth <= 512, "depth of xilinx block ram FIFO is 512");
    SyncFIFOIfc#(Bit#(w)) q <- mkXilinxSyncBramFifo(srcClk, srcRst, dstClk);

`else
    SyncFIFOIfc#(Bit#(w)) q <- mkSyncBRAMFIFO(depth, srcClk, srcRst, dstClk, dstRst);

`endif

    // guard sync fifo operations
    ResetGuard srcGuard <- mkResetGuard(clocked_by srcClk, reset_by srcRst);
    ResetGuard dstGuard <- mkResetGuard(clocked_by dstClk, reset_by dstRst);

    method notFull = q.notFull && srcGuard.isReady;
    method Action enq(t x) if(srcGuard.isReady);
        q.enq(zeroExtend(pack(x)));
    endmethod

    method notEmpty = q.notEmpty && dstGuard.isReady;
    method t first if(dstGuard.isReady);
        return unpack(truncate(q.first));
    endmethod
    method Action deq if(dstGuard.isReady);
        q.deq;
    endmethod
endmodule
