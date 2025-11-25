module instrMem(
    input  logic [31:0] addr, // full 32-bit CPU address comes in from PC
    output logic [31:0] instr
);

//memory map says 0xBFC00000 -> 0xBFC00FFF ... 4KB alloced
logic [7:0] instructions [2**12-1:0]; 
//double check CPU instrs are properly mapped to required range
// addr = PC - 32'hBFC00000
// simple: I believe this is done by the assembler which shows addresses starting index 0
//  PC==0 in simulation corresponds to the linked address 0xBFC0000
//ie by Linker - not rtl

initial begin
    $readmemh("pdf.hex", instructions); // probability density function test instructions loaded
end

//little endian - BYTE addressed
always_comb begin
    instr = { instructions[addr + 3], instructions[addr + 2], instructions[addr +1], instructions[addr]}; 
end

endmodule
