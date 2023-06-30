module mips_top (
    input                             clk,
    input                             rst_n,
    input[`INST_DATA_WIDTH-1:0]       rom_data_in,

    output wire[`INST_ADDR_WIDTH-1:0]  rom_addr_out,
    output wire                        rom_enable
);
//pc to id
    wire [`INST_DATA_WIDTH-1:0] inst_data_if2id;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data1_2id;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data2_2id;

//id to reg
    wire [`REG_ADDR_WIDTH-1:0]  reg_rd_addr1_2reg;
    wire [`REG_ADDR_WIDTH-1:0]  reg_rd_addr2_2reg;
    wire                        reg_rd_en1_2reg;
    wire                        reg_rd_en2_2reg;

//id to ex    
    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2ex;
    wire                        reg_wr_en_2ex;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data1_2ex;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data2_2ex;
    wire [`ALUSEL_WIDTH-1:0]    alusel_2ex;
    wire [`ALUOP_WIDTH-1:0]    aluop_2ex;

    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2ex_dly;
    wire                        reg_wr_en_2ex_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data1_2ex_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data2_2ex_dly;
    wire [`ALUSEL_WIDTH-1:0]    alusel_2ex_dly;
    wire [`ALUOP_WIDTH-1:0]    aluop_2ex_dly;

//ex to mem
    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2mem;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2mem;
    wire                        reg_wr_en_2mem;

    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2mem_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2mem_dly;
    wire                        reg_wr_en_2mem_dly;

//mem to wb
    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2wb;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2wb;
    wire                        reg_wr_en_2wb;

    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2wb_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2wb_dly;
    wire                        reg_wr_en_2wb_dly;


    pc pc0(
        .clk(clk),
        .rst_n(rst_n),
        .addr_to_rom(rom_addr_out),
        .pc_enable(rom_enable)
    );

    if_id if_id0(
        .clk(clk),
        .rst_n(rst_n),
        .inst_in(rom_data_in),
        .inst_out(inst_data_if2id)
    );

    id id0(
        .rst_n(rst_n),
        .inst_data_in(inst_data_if2id),
        .reg_rd_data1_in(reg_rd_data1_2id),
        .reg_rd_data2_in(reg_rd_data2_2id),
        .reg_rd_addr1_out(reg_rd_addr1_2reg),
        .reg_rd_addr2_out(reg_rd_addr2_2reg),
        .reg_rd_en1_out(reg_rd_en1_2reg),
        .reg_rd_en2_out(reg_rd_en2_2reg),
        .reg_wr_addr_out(reg_wr_addr_2ex),
        .reg_wr_en_out(reg_wr_en_2ex),
        .reg_rd_data1_out(reg_rd_data1_2ex),
        .reg_rd_data2_out(reg_rd_data2_2ex),
        .alusel_out(alusel_2ex),
        .aluop_out(aluop_2ex)
    );

    regs regs0(
        .clk(clk),
        .rst_n(rst_n),
        .waddr(reg_wr_addr_2wb_dly),
        .wdata(reg_wr_data_2wb_dly),
        .raddr1(reg_rd_addr1_2reg),
        .raddr2(reg_rd_addr1_2reg),
        .we(reg_wr_en_2wb_dly),
        .re1(reg_rd_en1_2reg),
        .re2(reg_rd_en2_2reg),
        .rdata1(reg_rd_data1_2id),
        .rdata2(reg_rd_data2_2id)
    );

    id_ex id_ex0(
        .clk(clk),
        .rst_n(rst_n),
        .reg_wr_addr_in(reg_wr_addr_2ex),
        .reg_wr_en_in(reg_wr_en_2ex),
        .reg_rd_data1_in(reg_rd_data1_2ex),
        .reg_rd_data2_in(reg_rd_data2_2ex),
        .alusel_in(alusel_2ex),
        .aluop_in(aluop_2ex),
        .reg_wr_addr_out(reg_wr_addr_2ex_dly),
        .reg_wr_en_out(reg_wr_en_2ex_dly),
        .reg_rd_data1_out(reg_rd_data1_2ex_dly),
        .reg_rd_data2_out(reg_rd_data2_2ex_dly),
        .alusel_out(alusel_2ex_dly),
        .aluop_out(aluop_2ex_dly) 
    );

    ex ex0(
        .rst_n(rst_n),
        .alusel_in(alusel_2ex_dly),
        .aluop_in(aluop_2ex_dly),
        .reg1_in(reg_rd_data1_2ex_dly),
        .reg2_in(reg_rd_data2_2ex_dly),
        .w_reg_addr_in(reg_wr_addr_2ex_dly),
        .w_reg_en_in(reg_wr_en_2ex_dly),
        .w_reg_addr_out(reg_wr_addr_2mem),
        .w_reg_data_out(reg_wr_data_2mem),
        .w_reg_en_out(reg_wr_en_2mem)
    );

    ex_mem ex_mem0(
        .clk(clk),
        .rst_n(rst_n),
        .w_reg_addr_in(reg_wr_addr_2mem),
        .w_reg_data_in(reg_wr_data_2mem),
        .w_reg_en_in(reg_wr_en_2mem),
        .w_reg_addr_out(reg_wr_addr_2mem_dly),
        .w_reg_data_out(reg_wr_data_2mem_dly),
        .w_reg_en_out(reg_wr_en_2mem_dly)
    );

    mem mem0(
        .rst_n(rst_n),
        .w_reg_addr_in(reg_wr_addr_2mem_dly),
        .w_reg_data_in(reg_wr_data_2mem_dly),
        .w_reg_en_in(reg_wr_en_2mem_dly),
        .w_reg_addr_out(reg_wr_addr_2wb),
        .w_reg_data_out(reg_wr_data_2wb),
        .w_reg_en_out(reg_wr_en_2wb)
    );

    mem_wb mem_wb0(
        .clk(clk),
        .rst_n(rst_n),
        .w_reg_addr_in(reg_wr_addr_2wb),
        .w_reg_data_in(reg_wr_data_2wb),
        .w_reg_en_in(reg_wr_en_2wb),
        .w_reg_addr_out(reg_wr_addr_2wb_dly),
        .w_reg_data_out(reg_wr_data_2wb_dly),
        .w_reg_en_out(reg_wr_en_2wb_dly)
    );

    
endmodule