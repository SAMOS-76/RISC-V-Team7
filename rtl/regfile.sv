module regfile(
    input clk,
    input write_en,
    input rst,

    input logic [4:0] a1,
    input logic [4:0] a2,
    input logic [4:0] a3,

    input logic [31:0] din,

    output logic [31:0] rout1,
    output logic [31:0] rout2 //watch trailing commas boys ! -eg was here 

);

//could parameterize in the future
logic [31:0] register [31:0];


//must reset all 32 Regs 
always_ff @(posedge clk, posedge rst) begin
    if(rst) begin

        for(int i=0; i<32; i++)begin
         register[i] <= 32'b0;
        end
    
    end

// this was overwriting x0 if a3 ==0 !! Must be hardwired to 0.
//and block writes to x0
    else if(write_en && a3 != 5'b0) begin
    
        register[a3] <= din;
    
    end


end

// likely need updating to avoid pipe hazards eventually
//overide x0 READS -HARD
assign rout1 = (a1 == 5'b0) ? 32'b0 : register[a1];
assign rout2 = (a2 == 5'b0) ? 32'b0 : register[a2];

    
endmodule
