module datamem #()(
    input clk,
    input write_en,

    input logic [4:0] write_addr,
    input logic [4:0] read_addr,

    input logic [31:0] din,

    output logic [31:0] dout

);


 logic [7:0] register [31:0];


always_ff @(posedge clk) begin

    else if(write_en) begin
    
            //different writes
    
    end


end

            //different reads

endmodule