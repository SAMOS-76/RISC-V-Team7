module instrMem(
    input  logic [31:0] addr, // full 32-bit CPU address comes in from PC
    output logic [31:0] instr
);

//memory map says 0xBFC00000 -> 0xBFC00FFF ... 4KB alloced
logic [7:0] instructions [2**12-1:0]; 
//double check CPU instrs are properly mapped to required range

initial begin
    $readmemh("program.hex", instructions);
end

//little endian - BYTE addressed
always_comb begin
    instr = { instructions[addr + 3], instructions[addr + 2], instructions[addr +1], instructions[addr]}; 
end

endmodule
