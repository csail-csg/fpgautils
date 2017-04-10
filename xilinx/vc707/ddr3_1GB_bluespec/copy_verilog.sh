#!/bin/bash

src_dir="$BLUESPECDIR/board_support/bluenoc/xilinx/VC707/verilog/ddr3_v2_0/ddr3_v2_0/user_design/rtl"
dst_dir="."

src_files=`find $src_dir -name "*.v"`

# check duplicate names (should not exist)
dup_files=$(for src in $src_files; do echo `basename $src`; done | sort | uniq -d)
if ! [ -z $dup_files ]; then
    echo "duplicated files names: $dup_files"
    exit
fi

# copy files here
for src in $src_files; do
    filename=`basename $src`
    if [ $filename = "ddr3_wrapper.v" ]; then
        echo "skip $src"
    else
        echo "copy $src"
        cp $src $dst_dir/
        chmod 444 $dst_dir/$filename
    fi
done
