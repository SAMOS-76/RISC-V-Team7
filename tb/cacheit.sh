#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
CACHE_TESTING_FOLDER=$(realpath "$SCRIPT_DIR/cache_testing")
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl")
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

passes=0
fails=0

cd $SCRIPT_DIR

rm -rf cache_testing/test_out/*


file="${CACHE_TESTING_FOLDER}/verify_cache.cpp"
name="top"

rtl_dirs=($(find "$RTL_FOLDER" -type d))

y_args=()
for d in "${rtl_dirs[@]}"; do
    y_args+=(-y "$d")
done

echo "${GREEN}Building cache tests...${RESET}"


verilator -Wall --trace \
             -cc ${RTL_FOLDER}/${name}.sv \
             --exe ${file} \
        "${y_args[@]}" \
             --prefix "Vdut" \
             -o Vdut \
             -CFLAGS "-DMODULE_NAME=\\\"cache\\\"" \
             -LDFLAGS "-lgtest -lgtest_main -lpthread"

make -j -C obj_dir/ -f Vdut.mk

echo "${GREEN}Running cache tests...${RESET}"


# Pass any command-line arguments to the test executable
./obj_dir/Vdut "$@"

if [ $? -eq 0 ]; then
    echo "${GREEN}All cache tests passed!${RESET}"
    passes=7
else
    echo "${RED}Some cache tests failed!${RESET}"
    fails=1
fi

mv obj_dir cache_testing/test_out/

echo ""
echo "${GREEN}Passed: ${passes}${RESET}"
echo "${RED}Failed: ${fails}${RESET}"
