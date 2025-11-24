module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst, 
);

    logic [1:0] PCSrc,


    fetch fetch(
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),
        .Result(),
        .ImmExt(),
        .Instr(),
        .pc_out4()
    );

    decode decode(
        .clk(clk),
        .rst(rst),
        .instr(),
        .data_in(),
        .PCSrc(PCSrc),
        .result_src(),
        .mem_write(),
        .alu_control(),
        .addr_mode(),
        .alu_srcA(),
        .alu_srcB(),
        .zero(),
        .sign_ext_flag(),
        .imm_ext(),
        .r_out1(),
        .r_out2(),
        .type_control()
    );

    execute execute(
        .clk(clk),
        .rst(rst),
        .pc(),
        .pc4(),
        .zero(),
        .alu_control(),
        .alu_srcA(),
        .alu_srcB(),
        .r_out1(),
        .r_out2(),
        .imm_ext(),
        .addr_mode(),
        .write_en(),
        .type_control(),
        .result_src(),
        .result()
    );


endmodule
