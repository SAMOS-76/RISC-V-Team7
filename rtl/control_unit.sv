module control_unit (
    input logic [31:0] instr,

    output logic [3:0]  aluControl,
    output logic        aluSrc,
    output logic        memWrite,
    output logic [1:0]  memSize,
    output logic        memUnsigned,
    output logic        regWrite,
    output logic [1:0]  resultSrc,
    output logic        branch,
    output logic        jump,
    output logic [2:0]  branchType,
    output logic [2:0]  immSrc
);

always_comb begin
    
end
    
endmodule