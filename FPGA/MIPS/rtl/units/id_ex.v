module id_ex (
    input                        rst_n,//sync rst, low valid
    input                        clk,
    input[`CTRL_WIDTH-1:0]       stall,

    input[`REG_ADDR_WIDTH-1:0]  reg_wr_addr_in,
    input                       reg_wr_en_in,
    input[`REG_DATA_WIDTH-1:0]  reg_rd_data1_in,
    input[`REG_DATA_WIDTH-1:0]  reg_rd_data2_in,
    input[`ALUSEL_WIDTH-1:0]    alusel_in,
    input[`ALUOP_WIDTH-1:0]     aluop_in,

    output reg[`REG_ADDR_WIDTH-1:0]  reg_wr_addr_out,
    output reg                       reg_wr_en_out,
    output reg[`REG_DATA_WIDTH-1:0]  reg_rd_data1_out,
    output reg[`REG_DATA_WIDTH-1:0]  reg_rd_data2_out,
    output reg[`ALUSEL_WIDTH-1:0]    alusel_out,
    output reg[`ALUOP_WIDTH-1:0]     aluop_out
);

    always @(posedge clk) begin
        if(!rst_n) begin
            reg_wr_addr_out <= 0;
            reg_wr_en_out <= 0;
            reg_rd_data1_out <= 0;
            reg_rd_data2_out <= 0;
            alusel_out <= 0;
            aluop_out <= 0;
        end else if(stall[2] == 1 && stall[3] == 0) begin
            reg_wr_addr_out <= 0;
            reg_wr_en_out <= 0;
            reg_rd_data1_out <= 0;
            reg_rd_data2_out <= 0;
            alusel_out <= 0;
            aluop_out <= 0;
        end else if(stall[2] == 0) begin
            reg_wr_addr_out <= reg_wr_addr_in;
            reg_wr_en_out <= reg_wr_en_in;
            reg_rd_data1_out <= reg_rd_data1_in;
            reg_rd_data2_out <= reg_rd_data2_in;
            alusel_out <= alusel_in;
            aluop_out <= aluop_in;
        end
    end


endmodule
