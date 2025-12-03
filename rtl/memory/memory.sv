module memory #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    
    // control signals from EXE PL reg? 
    input logic mem_write,
    input logic mem_read,
    input logic [1:0]  type_control,
    input logic  sign_ext_flag,
    
    // data from EXe PL reg? 
    input logic [DATA_WIDTH-1:0]  alu_result,
    input logic [DATA_WIDTH-1:0]  write_data,
    
    output logic [DATA_WIDTH-1:0] alu_result_out,
    output logic [DATA_WIDTH-1:0] read_data
    output logic stall
);

   //pass through
    assign alu_result_out = addr;

    // signals between controller and sram
    logic [6:0]   sram_set_idx;
    logic      sram_write_en;
    logic [302:0] sram_wdata;
    logic [302:0]  sram_rdata;

    //internal scontroller and main mem
    logic [31:0]  main_mem_addr;
    logic [31:0]  main_mem_wdata ;
    logic      main_mem_write ;
    logic [1:0]   main_mem_type;
    logic [31:0]  main_mem_rdata;

    cache_sram sram_inst (
        .clk(clk),
        .set_index(sram_set_idx),
        .write_en(sram_write_en),
        .wdata(sram_wdata),
        .rdata(sram_rdata)
    );

    cache_controller controller_inst(
        .clk(clk),
        .rst(rst),
        
        //cpu
        .cpu_addr(addr),
        .cpu_wdata(write_data),
        .cpu_mem_write(mem_write) ,
        .cpu_mem_read(mem_read), 
        .cpu_type(type_control),
        .cpu_sign_ext(sign_ext_flag),
        .cpu_rdata(read_data),
        .stall(stall),

        //sram
        .sram_set_idx(sram_set_idx),
        .sram_write_en(sram_write_en),
        .sram_wdata(sram_wdata),
        .sram_rdata(sram_rdata),

        //main mem
        .mem_addr(main_mem_addr),
        .mem_wdata(main_mem_wdata),
        .mem_write_en(main_mem_write),
        .mem_type(main_mem_type) ,
        .mem_rdata(main_mem_rdata)
    ) ;

    datamem datamem_inst(
        .clk(clk),
        .write_en(main_mem_write),
        .type_control(main_mem_type),
        .addr(main_mem_addr),
        .din(main_mem_wdata),
        .sign_ext(1'b0), 
        .dout(main_mem_rdata)
    );

endmodule
