module regfile(
    input clk,
    input write_en,
    input rst,

    input logic [4:0] a1,
    input logic [4:0] a2,
    input logic [4:0] a3,

    input logic [31:0] din,

    output logic [31:0] rout1,
    output logic [31:0] rout2,

);


 logic [31:0] register [31:0];


always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
    
        register[0] <= 32'b0;
    
    end

    else if(write_en) begin
    
        register[a3] <= din;
    
    end


end

assign rout1 = register[a1];
assign rout2 = register[a2];
    
endmodule