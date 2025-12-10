#!/bin/bash

#clean
rm -rf obj_dir
rm -f vbuddy.vcd
rm -f program.hex

# key paths
RTL_DIR="../../rtl"
ASM_DIR="../asm"
PROGRAM_HEX_DIR="../"

# assemble
if [ -f "../assemble.sh" ] && [ -f "$ASM_DIR/f1.s" ]; then
    echo "assembling f1.s..."
    ../assemble.sh "$ASM_DIR/f1.s"
fi

# link Hex File
if [ -f "${PROGRAM_HEX_DIR}program.hex" ]; then
    ln -sf "${PROGRAM_HEX_DIR}program.hex" program.hex
    echo "Linked ${PROGRAM_HEX_DIR}program.hex to program.hex"
else
    echo "Warning: couldnt find program.hex "
fi

# run Verilator
verilator -Wall --trace \
    -cc "$RTL_DIR/top.sv" \
    --exe f1_tb.cpp \
    $(find "$RTL_DIR" -type d -exec echo -y {} \;) \
    --prefix "Vdut" \
    -Wno-WIDTH \
    -Wno-UNUSED

# build cpp
if [ $? -eq 0 ]; then
    set -e 
    echo "Building..."
    make -j -C obj_dir/ -f Vdut.mk Vdut

    # run sim
    echo "running sim"
    ./obj_dir/Vdut
else
    echo "Verilator failed."
    exit 1
fi