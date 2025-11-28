# #!/bin/bash

# # This script runs the Verilator testbench
# # Usage: ./f1.sh <file1.cpp> <file2.cpp> ...

# # Constants
# SCRIPT_DIR=$(dirname "$(realpath "$0")")
# TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
# RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl")

# GREEN=$(tput setaf 2)
# RED=$(tput setaf 1)
# RESET=$(tput sgr0)

# passes=0
# fails=0

# # If no arguments: run all testbench files
# if [[ $# -eq 0 ]]; then
#     files=("$TEST_FOLDER"/*.cpp)
# else
#     files=("$@")
# fi

# cd "$SCRIPT_DIR"
# rm -rf obj_dir

# # Loop through all selected files
# for file in "${files[@]}"; do
#     filename=$(basename "$file")

#     echo "Running test: $filename"

#     # Detect type of testbench
#     if [[ "$filename" == "f1_tb.cpp" ]]; then
#         top="top"     # RTL top module
#     elif [[ "$filename" == "vbuddytesting.cpp" ]]; then
#         top="top"     # same top module
#     else
#         echo "Skipping unknown testbench: $filename"
#         continue
#     fi

#     # Run Verilator
#     # verilator -Wall --trace \
#     #     -cc "$RTL_FOLDER/$top.sv" \
#     #     --exe "$file" \
#     #     -y "$RTL_FOLDER" \
#     #     --prefix "Vdut" \
#     #     -o Vdut \
#     #     -LDFLAGS "-lgtest -lgtest_main -lpthread"

#     # Gather all RTL subdirectories
#     rtl_dirs=($(find "$RTL_FOLDER" -type d))

#     # Build -y arguments
#     y_args=()
#     for d in "${rtl_dirs[@]}"; do
#         y_args+=(-y "$d")
#     done

#     verilator -Wall --trace \
#                  -cc ${RTL_FOLDER}/$top.sv \
#                  --exe ${file} \
#             "${y_args[@]}" \
#                  --prefix "Vdut" \
#                  -o Vdut \
#                  -LDFLAGS "-lgtest -lgtest_main -lpthread"

#     # Build generated C++ project
#     make -j -C obj_dir/ -f Vdut.mk

#     # Run simulation
#     ./obj_dir/Vdut
#     result=$?

#     # Update pass/fail counters
#     if [[ $result -eq 0 ]]; then
#         echo "${GREEN}PASS${RESET}: $filename"
#         ((passes++))
#     else
#         echo "${RED}FAIL${RESET}: $filename"
#         ((fails++))
#     fi
# done

# # Summary
# total=$((passes + fails))
# echo "======================================"
# if [[ $fails -eq 0 ]]; then
#     echo "${GREEN}Success! All $passes test(s) passed!${RESET}"
#     exit 0
# else
#     echo "${RED}Failure! $passes passed, $fails failed (total $total).${RESET}"
#     exit 1
# fi

#!/bin/bash

# This script runs Verilator tests AND assembles any .s file required by the test
# Usage: ./doit.sh f1_tb.cpp [or multiple .cpp files]

SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl")

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

passes=0
fails=0

# Select test files
if [[ $# -eq 0 ]]; then
    files=("$TEST_FOLDER"/*.cpp)
else
    files=("$@")
fi

cd "$SCRIPT_DIR"
rm -rf obj_dir
rm -rf test_out/*
mkdir -p test_out


ASM_FILE="asm/f1.s"
HEX_FILE="asm/f1.hex"

if [[ -f "$ASM_FILE" ]]; then
    echo "Assembling $ASM_FILE..."
    ./assemble.sh "$ASM_FILE"

    if [[ $? -ne 0 ]]; then
        echo "${RED}Assembly failed${RESET}"
        exit 1
    fi

    echo "${GREEN}Assembly complete:${RESET} $HEX_FILE"
else
    echo "${RED}No ASM file found at $ASM_FILE${RESET}"
fi

for file in "${files[@]}"; do
    filename=$(basename "$file")

    echo "Running test: $filename"

    top="top"

    rtl_dirs=($(find "$RTL_FOLDER" -type d))

    y_args=()
    for d in "${rtl_dirs[@]}"; do
        y_args+=(-y "$d")
    done

    verilator -Wall --trace \
        -cc "$RTL_FOLDER/$top.sv" \
        --exe "$file" \
        "${y_args[@]}" \
        --prefix "Vdut" \
        -o Vdut \
        -LDFLAGS "-lgtest -lgtest_main -lpthread"

    make -j -C obj_dir/ -f Vdut.mk

    ./obj_dir/Vdut
    result=$?

    if [[ $result -eq 0 ]]; then
        echo "${GREEN}PASS${RESET}: $filename"
        ((passes++))
    else
        echo "${RED}FAIL${RESET}: $filename"
        ((fails++))
    fi
done

mv obj_dir test_out/

total=$((passes + fails))
echo "==============================="

if [[ $fails -eq 0 ]]; then
    echo "${GREEN}All $passes tests passed!${RESET}"
    exit 0
else
    echo "${RED}$passes passed, $fails failed${RESET}"
    exit 1
fi
