module mem_wb (
    input                            clk,
    input                            rst_n,
    input[`CTRL_WIDTH-1:0]           stall,
    input[`REG_ADDR_WIDTH-1:0]       w_reg_addr_in,
    input[`REG_DATA_WIDTH-1:0]       w_reg_data_in,
    input                            w_reg_en_in,

    input[`REG_DATA_WIDTH-1:0]       hi_regs_in,
    input[`REG_DATA_WIDTH-1:0]       lo_regs_in,
    input                            hilo_wen_in,

    output reg[`REG_DATA_WIDTH-1:0]  hi_regs_out,
    output reg[`REG_DATA_WIDTH-1:0]  lo_regs_out,
    output reg                       hilo_wen_out,

    output reg[`REG_ADDR_WIDTH-1:0]  w_reg_addr_out,
    output reg[`REG_DATA_WIDTH-1:0]  w_reg_data_out,
    output reg                       w_reg_en_out
);
    always @(posedge clk) begin
        if(!rst_n) begin
            w_reg_addr_out <= 0;
            w_reg_data_out <= 0;
            w_reg_en_out   <= 0;
            hi_regs_out    <= 0;
            lo_regs_out    <= 0;
            hilo_wen_out   <= 0;
        end else if(stall[4] == 1 && stall[5] == 0) begin
            w_reg_addr_out <= 0;
            w_reg_data_out <= 0;
            w_reg_en_out   <= 0;
            hi_regs_out    <= 0;
            lo_regs_out    <= 0;
            hilo_wen_out   <= 0;
        end else if(stall[4] == 0) begin
            w_reg_addr_out <= w_reg_addr_in;
            w_reg_data_out <= w_reg_data_in;
            w_reg_en_out   <= w_reg_en_in;
            hi_regs_out    <= hi_regs_in;
            lo_regs_out    <= lo_regs_in;
            hilo_wen_out   <= hilo_wen_in;
        end
    end
    
endmodule