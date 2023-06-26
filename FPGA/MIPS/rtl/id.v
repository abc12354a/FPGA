module id (
    input                        rst_n,//sync rst, low valid
    input[`INST_DATA_WIDTH-1:0]  inst_data_in,
    input[`REG_DATA_WIDTH-1:0]   reg_rd_data1,
    input[`REG_DATA_WIDTH-1:0]   reg_rd_data2,
    
    output[`REG_ADDR_WIDTH-1:0]  reg_rd_addr1,
    output[`REG_ADDR_WIDTH-1:0]  reg_rd_addr2,
    output[`REG_ADDR_WIDTH-1:0]  reg_wr_addr,
    output[`REG_DATA_WIDTH-1:0]  reg_wr_data,
    output                       reg_rd_en1,
    output                       reg_rd_en2,
    output                       reg_wr_en,

    output                       
);
    
endmodule