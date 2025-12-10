module div #(
    parameter DATA_WIDTH = 32
)(
    input  logic clk,

    input  logic [DATA_WIDTH-1:0] dividend,
    input  logic [DATA_WIDTH-1:0] divisor,
    output logic [DATA_WIDTH-1:0] quotient,
    output logic [DATA_WIDTH-1:0] remainder,
    output logic is_finished,

    input  logic is_unsigned,
    input  logic triggered
);

    logic                     is_running;
    logic [5:0]               cycle;

    logic [DATA_WIDTH-1:0]    dividend_register;
    logic [DATA_WIDTH-1:0]    divider_register;
    logic [DATA_WIDTH-1:0]    quotient_reg;
    logic [DATA_WIDTH-1:0]    remainder_reg;

    logic                     signed_result;
    logic                     signed_remainder;

    logic [DATA_WIDTH-1:0]    possible_remainder;
    assign possible_remainder = {remainder_reg[DATA_WIDTH-2:0], dividend_register[DATA_WIDTH-1]};

    always_ff @(posedge clk) begin
        if (triggered && !is_running && !is_finished) begin
            if (divisor == 0) begin
                is_finished     <= 1;
                is_running   <= 0;
                quotient  <= is_unsigned ? 32'h7FFFFFFF : 32'hFFFFFFFF;
                remainder <= dividend;
            end 
            else begin
                is_running <= 1;
                is_finished   <= 0;
                cycle <= 0;

                if (!is_unsigned) begin
                    signed_remainder    <= dividend[DATA_WIDTH-1];
                    signed_result <= dividend[DATA_WIDTH-1] ^ divisor[DATA_WIDTH-1];
                    dividend_register <= dividend[DATA_WIDTH-1] ? -dividend : dividend;
                    divider_register  <= divisor[DATA_WIDTH-1]  ? -divisor  : divisor;
                end 
                else begin
                    dividend_register <= dividend;
                    divider_register  <= divisor;
                    signed_remainder       <= 0;
                    signed_result    <= 0;
                end

                quotient_reg <= '0;
                remainder_reg <= '0;
            end
        end

        else if (is_running) begin
            if (cycle < 32) begin
                dividend_register <= {dividend_register[DATA_WIDTH-2:0], 1'b0};

                if (possible_remainder >= divider_register) begin
                    remainder_reg <= possible_remainder - divider_register;
                    quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b1};
                end
                else begin
                    remainder_reg <= possible_remainder;
                    quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b0};
                end

                cycle <= cycle + 1;
            end
            else begin
                is_running <= 0;
                is_finished   <= 1;

                if (!is_unsigned) begin
                    quotient  <= signed_result ? -quotient_reg : quotient_reg;
                    remainder <= signed_remainder    ? -remainder_reg : remainder_reg;
                end 
                else begin
                    quotient  <= quotient_reg;
                    remainder <= remainder_reg;
                end
            end
        end

        else if (!triggered && is_finished) begin
            is_finished <= 0;
        end
    end

endmodule
