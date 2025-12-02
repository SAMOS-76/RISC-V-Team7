module control_hazard (
    input logic        branch_mispredict,
    input logic [31:0] PCTarget,

    output logic       PCSrc,
    output logic       FlushF_D;
    output logic       FlushD_E,
);
    always_comb begin : blockName
        PCSrc  = 1'b0; // Take PC+4 by default
        FlushD = 1'b0;
        FlushF = 1'b0;

        if (branch_mispredict) begin
            FlushD = 1'b1;
            FlushF = 1'b1;
            PCSrc  = 1'b1;
        end
    end

endmodule