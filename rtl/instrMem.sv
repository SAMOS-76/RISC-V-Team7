module instrMem(
    input logic [9:0]   addr,   
    output logic [31:0] instr
);

logic [31:0] instructions [2**10-1:0];

initial begin
    $readmemh("pdf.hex", instructions); // probability density function test instructions loaded
end

assign instr = instructions[addr];

endmodule