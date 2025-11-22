#!/bin/bash

# get module name from cmd line
MODULE=$1

# Check if user provided a name
if [ -z "$MODULE" ]; then
    echo "Error: No module name provided."
    echo "Usage: ./doitunit.sh <module_name>"
    echo "Example: ./doitunit.sh regfile"
    exit 1
fi

#define variables for paths and names
#    CRITICAL: Use relative path (../) for TEST_SOURCE so make works inside obj_dir
RTL_SOURCE="../../rtl/${MODULE}.sv"
TEST_SOURCE="../verify_${MODULE}.cpp" 
TOP_MODULE="V${MODULE}"

#cleanup
rm -rf obj_dir
rm -f *.vcd  #get rid of this if we want to keep VCDs. 

# run Verilator
echo "Compiling RTL: $RTL_SOURCE"
echo "Using Test:  $TEST_SOURCE"

verilator   -Wall --trace \
            -cc "$RTL_SOURCE" \
            --exe "$TEST_SOURCE" \
            --prefix "$TOP_MODULE" \
            -I../../rtl \
             -CFLAGS "-std=c++17 -I.. -DMODULE_NAME=\\\"${MODULE}\\\"" \
            -LDFLAGS " -lgtest -lpthread"
            #lgtest_main will run all tests if want
            #watch for hidden space after \'s'

# Check for failure
if [ $? -ne 0 ]; then
    echo "Verilator translation failed!"
    exit 1
fi

# build
make -j -C obj_dir/ -f "${TOP_MODULE}.mk"

# run
if [ $? -eq 0 ]; then
    echo "Build successful. Running tests for $MODULE..."
    ./obj_dir/"$TOP_MODULE"
else
    echo "Build failed!"
    exit 1
fi