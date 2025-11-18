verilator --cc alu.sv --exe alu_tb.cpp --build \
    CXXFLAGS="-I./gtest/include" -Wall