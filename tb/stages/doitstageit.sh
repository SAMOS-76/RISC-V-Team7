#!/bin/bash

STAGE="$1"
RTL_PATH="../../rtl/${STAGE}/${STAGE}.sv"

# do files actually exist
if [ ! -f "${STAGE}_verify.cpp" ]; then
    echo " ${STAGE}_verify.cpp not found"
    exit 1
fi

if [ ! -f "$RTL_PATH" ]; then
    echo "$RTL_PATH not found"
    exit 1
fi

# Clean up
rm -rf obj_dir *.vcd
touch data.hex

# Compile and run
verilator -Wall --trace \
          -cc "$RTL_PATH" \
          --exe "${STAGE}_verify.cpp" \
          --prefix "V${STAGE}" \
          -I../../rtl/${STAGE} \
          -CFLAGS "-std=c++17 -I../Units" \
          -LDFLAGS "-lgtest -lpthread" \
&& make -j -C obj_dir/ -f "V${STAGE}.mk" \
&& ./obj_dir/"V${STAGE}"

if [ $? -eq 0 ]; then
    echo "confirmed"
else
    echo "failed or other error"
    exit 1
fi


















