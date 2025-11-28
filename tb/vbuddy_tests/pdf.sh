#!/bin/bash

# clean
rm -rf obj_dir
rm -f pdf.vcd
rm -f data.hex
rm -f program.hex

# load desired .mem file for pdf : eg : gaussian, triangle, noisy... 
# eg ran via: 
#./pdf.sh triangle
DISTRO=${1:-gaussian} #obvs deafult
REF_DIR="../reference"

if [ -f "${REF_DIR}/${DISTRO}.mem" ]; then
    cp "${REF_DIR}/${DISTRO}.mem" data.hex
    echo "Loaded ${DISTRO} distribution."
else
    echo "Error: Could not find ${DISTRO}.mem in ${REF_DIR}"
    exit 1
fi

# assemble - progam.hex
../assemble.sh "${REF_DIR}/pdf.s"

#point at program hex
if [ -f ../program.hex ]; then
    ln -sf ../program.hex program.hex
    echo "Linked program.hex"
else
    echo "Error: ../program.hex not found. Assembly might have failed."
    exit 1
fi

# run Verilator
echo "Verilating..."
verilator -Wall --trace \
    -cc ../../rtl/top.sv \
    --exe pdf_tb.cpp \
    $(find ../../rtl -type d -exec echo -y {} \;) \
    --prefix "Vdut" \
    -Wno-WIDTH \
    -Wno-UNUSED

# use make for cpp
set -e 
echo "Building..."
make -j -C obj_dir/ -f Vdut.mk Vdut


echo "Running Simulation..."
./obj_dir/Vdut