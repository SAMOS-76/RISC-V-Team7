#!/bin/bash

#clean
rm -rf obj_dir
rm -f vbuddy.vcd program.hex data.hex

#key paths 
RTL_DIR="../../rtl"
ASM_DIR="../asm"

# assemble
../assemble.sh "$ASM_DIR/f1.s"

# link program hex 
if [ -f "../program.hex" ]; then
    ln -sf "../program.hex" program.hex
    echo "Linked program.hex"
else
    echo "program.hex not found"
    exit 1
fi

# run verilator
verilator -Wall --trace \
    -cc "$RTL_DIR/top.sv" \
    --exe f1_tb.cpp \
    $(find "$RTL_DIR" -type d -printf "-y %p ") \
    --prefix "Vdut" \
    -Wno-WIDTH \
    -Wno-UNUSED

# build and run
set -e
make -j -C obj_dir/ -f Vdut.mk Vdut
echo "Running simulation..."
./obj_dir/Vdut