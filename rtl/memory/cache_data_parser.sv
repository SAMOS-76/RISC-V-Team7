module cache_data_parser #(
    parameter DATA_WIDTH = 32
)(
    //controls
    input logic [1:0] type_control,
    input logic [1:0] byte_offset,
    input logic sign_ext,

    input logic [DATA_WIDTH-1:0] cache_line_data,
    output logic [DATA_WIDTH-1:0] extracted_data,

    input logic [DATA_WIDTH-1:0] write_data,
    input logic [DATA_WIDTH-1:0] base_data,
    output logic [DATA_WIDTH-1:0] merged_data
);

    logic is_halfword_access, is_byte_access;
    logic halfword_upper;

    assign is_halfword_access = (type_control == 2'b01);
    assign is_byte_access = (type_control == 2'b00);
    assign halfword_upper = byte_offset[1];

    always_comb begin
        if (is_byte_access) begin
            case (byte_offset)
                2'b00: extracted_data = {{24{sign_ext & cache_line_data[7]}}, cache_line_data[7:0]};
                2'b01: extracted_data = {{24{sign_ext & cache_line_data[15]}}, cache_line_data[15:8]};
                2'b10: extracted_data = {{24{sign_ext & cache_line_data[23]}}, cache_line_data[23:16]};
                2'b11: extracted_data = {{24{sign_ext & cache_line_data[31]}}, cache_line_data[31:24]};
            endcase
        end else if (is_halfword_access) begin
            if (halfword_upper)
                extracted_data = {{16{sign_ext & cache_line_data[31]}}, cache_line_data[31:16]};
            else
                extracted_data = {{16{sign_ext & cache_line_data[15]}}, cache_line_data[15:0]};
        end else begin
            extracted_data = cache_line_data;
        end
    end

    always_comb begin
        if (is_byte_access) begin
            merged_data = base_data;
            case (byte_offset)
                2'b00: merged_data[7:0] = write_data[7:0];
                2'b01: merged_data[15:8] = write_data[7:0];
                2'b10: merged_data[23:16] = write_data[7:0];
                2'b11: merged_data[31:24] = write_data[7:0];
            endcase
        end else if (is_halfword_access) begin
            merged_data = base_data;
            if (halfword_upper)
                merged_data[31:16] = write_data[15:0];
            else
                merged_data[15:0] = write_data[15:0];
        end else begin
            merged_data = write_data;
        end
    end

endmodule
