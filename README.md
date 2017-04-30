# fpgautils
This repo contains FPGA-related source files.
To use DDR3 on VC707 board, we need to copy the verilog files for DDR3 IP from Bluespec installation (environment variable `BLUESPECDIR` should point to the lib folder in Bluespec installation):
```
cd xilinx/vc707/ddr3_1GB_bluespec
./copy_verilog.sh
```

