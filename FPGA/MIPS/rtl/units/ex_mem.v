module ex_mem (
    input           clk,
    input           rst_n,

    input[`REG_ADDR_WIDTH-1:0]  w_reg_addr_in,
    input[`REG_DATA_WIDTH-1:0]  w_reg_data_in,
    input                       w_reg_en_in,

    output reg[`REG_ADDR_WIDTH-1:0] w_reg_addr_out,
    output reg[`REG_DATA_WIDTH-1:0] w_reg_data_out,
    output reg                      w_reg_en_out
);

    always @(posedge clk) begin
        if(!rst_n) begin
            w_reg_addr_out   <= 0;
            w_reg_data_out   <= 0;
            w_reg_en_out     <= 0;
        end else begin
            w_reg_addr_out   <= w_reg_addr_in;
            w_reg_data_out   <= w_reg_data_in;
            w_reg_en_out     <= w_reg_en_in;
        end
    end
    
endmodule