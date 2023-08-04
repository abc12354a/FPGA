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

//hilo regs to ex
    wire [`REG_DATA_WIDTH-1:0]  hi_regs_2ex;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_2ex;
    wire                        hilo_wen_2ex;

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
    wire [`ALUOP_WIDTH-1:0]     aluop_2ex;

    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2ex_dly;
    wire                        reg_wr_en_2ex_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data1_2ex_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_rd_data2_2ex_dly;
    wire [`ALUSEL_WIDTH-1:0]    alusel_2ex_dly;
    wire [`ALUOP_WIDTH-1:0]     aluop_2ex_dly;

//id to ctrl
    wire [0:0]                  ctrl_req_from_id;

//ex to mem
    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2mem;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2mem;
    wire                        reg_wr_en_2mem;

    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2mem_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2mem_dly;
    wire                        reg_wr_en_2mem_dly;

    wire [`REG_DATA_WIDTH-1:0]  hi_regs_2mem;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_2mem;
    wire                        hilo_wen_2mem;

    wire [`REG_DATA_WIDTH-1:0]  hi_regs_2mem_dly;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_2mem_dly;
    wire                        hilo_wen_2mem_dly;

    wire [64-1:0]               hilo_tmp_2mem_dly;
    wire [1:0]                  mul_cnt_2mem_dly;
    wire [64-1:0]               hilo_tmp_2ex;
    wire [1:0]                  mul_cnt_2ex;

//ex to id
    wire[`REG_ADDR_WIDTH-1:0]   reg_wr_waddr_ex2id = reg_wr_addr_2mem;
    wire[`REG_DATA_WIDTH-1:0]   reg_wr_wdata_ex2id = reg_wr_data_2mem;
    wire                        reg_wr_en_ex2id = reg_wr_en_2mem;

//ex to ctrl
    wire [0:0]                  ctrl_req_from_ex;

//mem to wb
    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2wb;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2wb;
    wire                        reg_wr_en_2wb;

    wire [`REG_ADDR_WIDTH-1:0]  reg_wr_addr_2wb_dly;
    wire [`REG_DATA_WIDTH-1:0]  reg_wr_data_2wb_dly;
    wire                        reg_wr_en_2wb_dly;

    wire [`REG_DATA_WIDTH-1:0]  hi_regs_2wb;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_2wb;
    wire                        hilo_wen_2wb;

    wire [`REG_DATA_WIDTH-1:0]  hi_regs_2wb_dly;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_2wb_dly;
    wire                        hilo_wen_2wb_dly;

//mem to ex
    wire [`REG_DATA_WIDTH-1:0]  hi_regs_mem2ex = hi_regs_2wb;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_mem2ex = lo_regs_2wb;
    wire                        hilo_wen_mem2ex = hilo_wen_2wb;

//mem to id
    wire[`REG_ADDR_WIDTH-1:0]   reg_wr_waddr_mem2id = reg_wr_addr_2wb;
    wire[`REG_DATA_WIDTH-1:0]   reg_wr_wdata_mem2id = reg_wr_data_2wb;
    wire                        reg_wr_en_mem2id = reg_wr_en_2wb;

//wb to ex
    wire [`REG_DATA_WIDTH-1:0]  hi_regs_wb2ex = hi_regs_2wb_dly;
    wire [`REG_DATA_WIDTH-1:0]  lo_regs_wb2ex = lo_regs_2wb_dly;
    wire                        hilo_wen_wb2ex = hilo_wen_2wb_dly;

// ctrl to modules
    wire [`CTRL_WIDTH-1:0]      ctrl_out;

    pc pc0(
        .clk(clk),
        .rst_n(rst_n),
        .stall(ctrl_out),
        .addr_to_rom(rom_addr_out),
        .pc_enable(rom_enable)
    );

    if_id if_id0(
        .clk(clk),
        .rst_n(rst_n),
        .stall(ctrl_out),
        .inst_in(rom_data_in),
        .inst_out(inst_data_if2id)
    );

    id id0(
        .rst_n(rst_n),
        .inst_data_in(inst_data_if2id),
        .reg_rd_data1_in(reg_rd_data1_2id),
        .reg_rd_data2_in(reg_rd_data2_2id),
        .ex_waddr_in(reg_wr_waddr_ex2id),
        .ex_wdata_in(reg_wr_wdata_ex2id),
        .ex_wen_in(reg_wr_en_ex2id),
        .mem_waddr_in(reg_wr_waddr_mem2id),
        .mem_wdata_in(reg_wr_wdata_mem2id),
        .mem_wen_in(reg_wr_en_mem2id),
        .stall_req(ctrl_req_from_id),
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
        .raddr2(reg_rd_addr2_2reg),
        .we(reg_wr_en_2wb_dly),
        .re1(reg_rd_en1_2reg),
        .re2(reg_rd_en2_2reg),
        .rdata1(reg_rd_data1_2id),
        .rdata2(reg_rd_data2_2id)
    );

    id_ex id_ex0(
        .clk(clk),
        .rst_n(rst_n),
        .stall(ctrl_out),
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
        .hi_regs_in(hi_regs_2ex),
        .lo_regs_in(lo_regs_2ex),
        .wb_hi_regs_in(hi_regs_wb2ex),
        .wb_lo_regs_in(lo_regs_wb2ex),
        .wb_hilo_wen(hilo_wen_wb2ex),
        .mem_hi_regs_in(hi_regs_mem2ex),
        .mem_lo_regs_in(lo_regs_mem2ex),
        .mem_hilo_wen(hilo_wen_mem2ex),
        .hilo_tmp_in(hilo_tmp_2ex),
        .mul_cnt_in(mul_cnt_2ex),
        .stall_req(ctrl_req_from_ex),
        .w_reg_addr_out(reg_wr_addr_2mem),
        .w_reg_data_out(reg_wr_data_2mem),
        .w_reg_en_out(reg_wr_en_2mem),
        .hilo_tmp_out(hilo_tmp_2mem_dly),
        .mul_cnt_out(mul_cnt_2mem_dly),
        .hi_regs_out(hi_regs_2mem),
        .lo_regs_out(lo_regs_2mem),
        .hilo_wen(hilo_wen_2mem)
    );

    ex_mem ex_mem0(
        .clk(clk),
        .rst_n(rst_n),
        .stall(ctrl_out),
        .w_reg_addr_in(reg_wr_addr_2mem),
        .w_reg_data_in(reg_wr_data_2mem),
        .w_reg_en_in(reg_wr_en_2mem),
        .hi_regs_in(hi_regs_2mem),
        .lo_regs_in(lo_regs_2mem),
        .hilo_wen_in(hilo_wen_2mem),
        .hilo_tmp_in(hilo_tmp_2mem_dly),
        .mul_cnt_in(mul_cnt_2mem_dly),
        .hi_regs_out(hi_regs_2mem_dly),
        .lo_regs_out(lo_regs_2mem_dly),
        .hilo_wen_out(hilo_wen_2mem_dly),
        .hilo_tmp_out(hilo_tmp_2ex),
        .mul_cnt_out(mul_cnt_2ex),
        .w_reg_addr_out(reg_wr_addr_2mem_dly),
        .w_reg_data_out(reg_wr_data_2mem_dly),
        .w_reg_en_out(reg_wr_en_2mem_dly)
    );

    mem mem0(
        .rst_n(rst_n),
        .w_reg_addr_in(reg_wr_addr_2mem_dly),
        .w_reg_data_in(reg_wr_data_2mem_dly),
        .w_reg_en_in(reg_wr_en_2mem_dly),
        .hi_regs_in(hi_regs_2mem_dly),
        .lo_regs_in(lo_regs_2mem_dly),
        .hilo_wen_in(hilo_wen_2mem_dly),
        .hi_regs_out(hi_regs_2wb),
        .lo_regs_out(lo_regs_2wb),
        .hilo_wen_out(hilo_wen_2wb),
        .w_reg_addr_out(reg_wr_addr_2wb),
        .w_reg_data_out(reg_wr_data_2wb),
        .w_reg_en_out(reg_wr_en_2wb)
    );

    mem_wb mem_wb0(
        .clk(clk),
        .rst_n(rst_n),
        .stall(ctrl_out),
        .w_reg_addr_in(reg_wr_addr_2wb),
        .w_reg_data_in(reg_wr_data_2wb),
        .w_reg_en_in(reg_wr_en_2wb),
        .hi_regs_in(hi_regs_2wb),
        .lo_regs_in(lo_regs_2wb),
        .hilo_wen_in(hilo_wen_2wb),
        .hi_regs_out(hi_regs_2wb_dly),
        .lo_regs_out(lo_regs_2wb_dly),
        .hilo_wen_out(hilo_wen_2wb_dly),
        .w_reg_addr_out(reg_wr_addr_2wb_dly),
        .w_reg_data_out(reg_wr_data_2wb_dly),
        .w_reg_en_out(reg_wr_en_2wb_dly)
    );

    hilo_regs hilo_regs0(
        .clk(clk),
        .rst_n(rst_n),
        .we(hilo_wen_2wb_dly),
        .hi_data_in(hi_regs_2wb_dly),
        .lo_data_in(lo_regs_2wb_dly),
        .hi_data_out(hi_regs_2ex),
        .lo_data_out(lo_regs_2ex)
    );

    ctrl ctrl0(
        .rst_n(rst_n),
        .stall_req_id(ctrl_req_from_id),
        .stall_req_ex(ctrl_req_from_ex),
        .stall(ctrl_out)
    );
endmodule