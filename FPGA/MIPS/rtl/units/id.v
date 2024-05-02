module id (
    input                        rst_n,//sync rst, low valid
    input[`INST_DATA_WIDTH-1:0]  inst_data_in,
    input[`INST_ADDR_WIDTH-1:0]  inst_addr_in,
    input                        delay_slot_flag_in,

    input[`REG_DATA_WIDTH-1:0]   reg_rd_data1_in,
    input[`REG_DATA_WIDTH-1:0]   reg_rd_data2_in,
    
    //ex_phase to id_phase, data forward
    input[`REG_ADDR_WIDTH-1:0]   ex_waddr_in,
    input[`REG_DATA_WIDTH-1:0]   ex_wdata_in,
    input                        ex_wen_in,
    //mem_phase to id_phase, data forward
    input[`REG_ADDR_WIDTH-1:0]   mem_waddr_in,
    input[`REG_DATA_WIDTH-1:0]   mem_wdata_in,
    input                        mem_wen_in,


    output reg                       stall_req,
    output reg                       branch_flag_out,
    output reg                       delay_slot_flag_out,
    output reg                       next_delay_slot_flag_out,
    output reg[`REG_ADDR_WIDTH-1:0]  branch_target_addr_out,
    output reg[`REG_ADDR_WIDTH-1:0]  link_addr_out,
    output reg[`REG_ADDR_WIDTH-1:0]  reg_rd_addr1_out,
    output reg[`REG_ADDR_WIDTH-1:0]  reg_rd_addr2_out,
    output reg                       reg_rd_en1_out,
    output reg                       reg_rd_en2_out,

    output reg[`REG_ADDR_WIDTH-1:0]  reg_wr_addr_out,
    output reg                       reg_wr_en_out,
    output reg[`REG_DATA_WIDTH-1:0]  reg_rd_data1_out,
    output reg[`REG_DATA_WIDTH-1:0]  reg_rd_data2_out,
    output reg[`ALUSEL_WIDTH-1:0]    alusel_out,
    output reg[`ALUOP_WIDTH-1:0]     aluop_out
);
    //-------------------------------------------
    //OP(31-26)| RS(25-21)| RT(20-16) | IM(15-0)|
    //-------------------------------------------
    reg                        inst_valid;
    reg[`REG_DATA_WIDTH-1:0]   imm_data;
    wire[`INST_ADDR_WIDTH-1:0] pc_4;
    wire[`INST_ADDR_WIDTH-1:0] pc_8;
    wire[`REG_DATA_WIDTH-1:0]  signed_ext;
    wire[6-1:0]       op = inst_data_in[31:26];
    wire[4:0]         rs = inst_data_in[25:21];
    wire[4:0]         rt = inst_data_in[20:16];
    wire[4:0]         wt = inst_data_in[15:11];
    wire[16-1:0]      im = inst_data_in[15:0];
    wire[5:0]    func_op = inst_data_in[5:0];
    wire[4:0]        op4 = inst_data_in[10:6];


    assign pc_4          = inst_addr_in + 'd4;
    assign pc_8          = inst_addr_in + 'd8;
    assign signed_ext    = {14{inst_data_in[15]},inst_data_in[15:0],2'b00};

    always @(*) begin
        stall_req = 0;
    end

    always @($) begin
        if(!rst_n)begin
            delay_slot_flag_out = 0;
        end else begin
            delay_slot_flag_out = delay_slot_flag_in;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            aluop_out = `EXE_NOP;
            alusel_out = `EXE_RES_NOP;
            inst_valid = 0;
            reg_rd_addr1_out = 0;
            reg_rd_addr2_out = 0;
            reg_wr_addr_out = 0;
            reg_rd_en1_out = 0;
            reg_rd_en2_out = 0;
            reg_wr_en_out = 0;
            imm_data = 0;
            branch_target_addr_out = 0;
            link_addr_out = 0;
            branch_flag_out = 0;
            delay_slot_flag_out = 0;
        end else begin
            aluop_out = `EXE_NOP;
            alusel_out = `EXE_RES_NOP;
            inst_valid = 0;
            reg_rd_addr1_out = rs;
            reg_rd_addr2_out = rt;
            reg_wr_addr_out = wt;
            reg_rd_en1_out = 0;
            reg_rd_en2_out = 0;
            reg_wr_en_out = 0;
            imm_data = 0;
            branch_target_addr_out = 0;
            link_addr_out = 0;
            branch_flag_out = 0;
            delay_slot_flag_out = 0;
            case (op)
                `EXE_SPEC: begin
                    case (op4)
                        5'b00000:begin
                            case (func_op)
                                `EXE_OR: begin
                                    aluop_out = `EXE_OR_OP;
                                    alusel_out = `EXE_RES_LOGIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end 
                                `EXE_AND: begin
                                    aluop_out = `EXE_AND_OP;
                                    alusel_out = `EXE_RES_LOGIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_XOR: begin
                                    aluop_out = `EXE_XOR_OP;
                                    alusel_out = `EXE_RES_LOGIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_NOR: begin
                                    aluop_out = `EXE_NOR_OP;
                                    alusel_out = `EXE_RES_LOGIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SLLV:begin
                                    aluop_out = `EXE_SLL_OP;
                                    alusel_out = `EXE_RES_SHIFT;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SRLV:begin
                                    aluop_out = `EXE_SRL_OP;
                                    alusel_out = `EXE_RES_SHIFT;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SRAV:begin
                                    aluop_out = `EXE_SRA_OP;
                                    alusel_out = `EXE_RES_SHIFT;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SYNC:begin
                                    aluop_out = `EXE_NOP_OP;
                                    alusel_out = `EXE_RES_NOP;
                                    reg_rd_en1_out = 0;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MOVN: begin
                                    aluop_out = `EXE_MOVN_OP;
                                    alusel_out = `EXE_RES_MOVE;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = reg_rd_data2_out == 0? 0:1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MOVZ: begin
                                    aluop_out = `EXE_MOVZ_OP;
                                    alusel_out = `EXE_RES_MOVE;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = reg_rd_data2_out == 0? 1:0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MFHI: begin
                                    aluop_out = `EXE_MFHI_OP;
                                    alusel_out = `EXE_RES_MOVE;
                                    reg_rd_en1_out = 0;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MFLO: begin
                                    aluop_out = `EXE_MFLO_OP;
                                    alusel_out = `EXE_RES_MOVE;
                                    reg_rd_en1_out = 0;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MTHI: begin
                                    aluop_out = `EXE_MTHI_OP;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MTLO: begin
                                    aluop_out = `EXE_MTLO_OP;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SLT: begin
                                    aluop_out = `EXE_SLT_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SLTU: begin
                                    aluop_out = `EXE_SLTU_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_ADD: begin
                                    aluop_out = `EXE_ADD_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_ADDU: begin
                                    aluop_out = `EXE_ADDU_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SUB: begin
                                    aluop_out = `EXE_SUB_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_SUBU: begin
                                    aluop_out = `EXE_SUBU_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MULT: begin
                                    aluop_out = `EXE_MULT_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_MULTU: begin
                                    aluop_out = `EXE_MULTU_OP;
                                    alusel_out = `EXE_RES_ARITHMETIC;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 1;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_DIV: begin
                                    aluop_out = `EXE_DIV_OP;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_DIVU: begin
                                    aluop_out = `EXE_DIVU_OP;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 1;
                                    reg_wr_en_out  = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_JR: begin
                                    aluop_out = `EXE_JR_OP;
                                    alusel_out = `EXE_RES_JUMP_BRANCH;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 0;
                                    branch_target_addr_out = reg_rd_data1_out;
                                    branch_flag_out = 1;
                                    next_delay_slot_flag_out = 1;
                                    link_addr_out = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                `EXE_JALR: begin
                                    aluop_out = `EXE_JALR_OP;
                                    alusel_out = `EXE_RES_JUMP_BRANCH;
                                    reg_rd_en1_out = 1;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 1;
                                    branch_target_addr_out = reg_rd_data1_out;
                                    branch_flag_out = 1;
                                    next_delay_slot_flag_out = 1;
                                    link_addr_out = pc_8;
                                    reg_rd_addr1_out = rs;
                                    reg_rd_addr2_out = rt;
                                    reg_wr_addr_out = wt;
                                    inst_valid = 1;
                                end
                                default: begin
                                    aluop_out = `EXE_NOP_OP;
                                    alusel_out = `EXE_RES_LOGIC;
                                    reg_rd_en1_out = 0;
                                    reg_rd_en2_out = 0;
                                    reg_wr_en_out  = 0;
                                    reg_rd_addr1_out = rs;
                                    reg_wr_addr_out = rt;
                                    inst_valid = 1;
                                end 
                            endcase
                        end 
                        default: begin
                            aluop_out = `EXE_NOP_OP;
                            alusel_out = `EXE_RES_LOGIC;
                            reg_rd_en1_out = 0;
                            reg_rd_en2_out = 0;
                            reg_wr_en_out  = 0;
                            reg_rd_addr1_out = rs;
                            reg_wr_addr_out = rt;
                            inst_valid = 1;
                        end
                    endcase
                end
                `EXE_SPEC2:begin
                    case (func_op)
                        `EXE_CLZ:begin
                            aluop_out = `EXE_CLZ_OP;
                            alusel_out = `EXE_RES_ARITHMETIC;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 0;
                            reg_wr_en_out  = 1;
                            reg_rd_addr1_out = rs;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;
                        end 
                        `EXE_CLO:begin
                            aluop_out = `EXE_CLO_OP;
                            alusel_out = `EXE_RES_ARITHMETIC;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 0;
                            reg_wr_en_out  = 1;
                            reg_rd_addr1_out = rs;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;
                        end
                        `EXE_MUL:begin
                            aluop_out = `EXE_MUL_OP;
                            alusel_out = `EXE_RES_MUL;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 1;
                            reg_wr_en_out  = 1;
                            reg_rd_addr1_out = rs;
                            reg_rd_addr2_out = rt;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;
                        end
                        `EXE_MADD: begin
                            aluop_out = `EXE_MADD_OP;
                            alusel_out = `EXE_RES_MUL;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 1;
                            reg_wr_en_out  = 0;
                            reg_rd_addr1_out = rs;
                            reg_rd_addr2_out = rt;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;
                        end
                        `EXE_MADDU: begin
                            aluop_out = `EXE_MADDU_OP;
                            alusel_out = `EXE_RES_MUL;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 1;
                            reg_wr_en_out  = 0;
                            reg_rd_addr1_out = rs;
                            reg_rd_addr2_out = rt;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;
                        end
                        `EXE_MSUB: begin
                            aluop_out = `EXE_MSUB_OP;
                            alusel_out = `EXE_RES_MUL;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 1;
                            reg_wr_en_out  = 0;
                            reg_rd_addr1_out = rs;
                            reg_rd_addr2_out = rt;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;                            
                        end
                        `EXE_MSUBU: begin
                            aluop_out = `EXE_MSUBU_OP;
                            alusel_out = `EXE_RES_MUL;
                            reg_rd_en1_out = 1;
                            reg_rd_en2_out = 1;
                            reg_wr_en_out  = 0;
                            reg_rd_addr1_out = rs;
                            reg_rd_addr2_out = rt;
                            reg_wr_addr_out = wt;
                            inst_valid = 1;                            
                        end
                        default: begin
                            
                        end
                    endcase
                end
                `EXE_ORI:  begin
                    aluop_out = `EXE_OR_OP;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {16'h0,im};
                    inst_valid = 1;
                end
                `EXE_ANDI: begin
                    aluop_out = `EXE_AND_OP;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {16'h0,im};
                    inst_valid = 1;
                end
                `EXE_XORI: begin
                    aluop_out = `EXE_XOR_OP;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {16'h0,im};
                    inst_valid = 1;
                end
                `EXE_LUI:  begin
                    aluop_out = `EXE_OR_OP;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {im,16'h0};
                    inst_valid = 1;
                end
                `EXE_PREF: begin
                    aluop_out = `EXE_NOP_OP;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 0;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 0;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    inst_valid = 1;
                end
                `EXE_SLTI: begin
                    aluop_out = `EXE_SLT_OP;
                    alusel_out = `EXE_RES_ARITHMETIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {{16{im[15]}},im};
                    inst_valid = 1;
                end
                `EXE_SLTIU: begin
                    aluop_out = `EXE_SLTU_OP;
                    alusel_out = `EXE_RES_ARITHMETIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {{16{im[15]}},im};
                    inst_valid = 1;
                end
                `EXE_ADDI: begin
                    aluop_out = `EXE_ADDI_OP;
                    alusel_out = `EXE_RES_ARITHMETIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {{16{im[15]}},im};
                    inst_valid = 1;
                end
                `EXE_ADDIU: begin
                    aluop_out = `EXE_ADDIU_OP;
                    alusel_out = `EXE_RES_ARITHMETIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {{16{im[15]}},im};
                    inst_valid = 1;
                end
                `EXE_J: begin
                    aluop_out = `EXE_J_OP;
                    alusel_out = `EXE_RES_ARITHMETIC;
                    reg_rd_en1_out = 0;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 0;
                    branch_target_addr_out = {pc_4[31:28],inst_data_in[25:0],2'b00};
                    branch_flag_out = 1;
                    reg_wr_addr_out = 0;
                    next_delay_slot_flag_out = 1;
                    link_addr_out = 0;
                    inst_valid = 1;
                end
                `EXE_JAL begin
                    aluop_out = `EXE_J_OP;
                    alusel_out = `EXE_RES_ARITHMETIC;
                    reg_rd_en1_out = 0;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1;
                    branch_target_addr_out = {pc_4[31:28],inst_data_in[25:0],2'b00};
                    branch_flag_out = 1;
                    reg_wr_addr_out = 5'b1_1111;//return to reg32
                    next_delay_slot_flag_out = 1;
                    link_addr_out = pc_8;
                    inst_valid = 1;
                end
                default:   begin
                    aluop_out = `EXE_NOP_OP;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 0;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 0;
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    inst_valid = 1;
                end
            endcase
            if(op == 'b0 && rs == 'b0) begin 
                case (func_op)
                    `EXE_SLL: begin
                        aluop_out = `EXE_SLL_OP;
                        alusel_out = `EXE_RES_SHIFT;
                        reg_rd_en1_out = 0;
                        reg_rd_en2_out = 1;
                        reg_wr_en_out  = 1;
                        reg_rd_addr1_out = rs;
                        reg_rd_addr2_out = rt;
                        reg_wr_addr_out = wt;
                        imm_data = {27'h0,op4};
                        inst_valid = 1;
                    end 
                    `EXE_SRL: begin
                        aluop_out = `EXE_SRL_OP;
                        alusel_out = `EXE_RES_SHIFT;
                        reg_rd_en1_out = 0;
                        reg_rd_en2_out = 1;
                        reg_wr_en_out  = 1;
                        reg_rd_addr1_out = rs;
                        reg_rd_addr2_out = rt;
                        reg_wr_addr_out = wt;
                        imm_data = {27'h0,op4};
                        inst_valid = 1;
                    end
                    `EXE_SRA: begin
                        aluop_out = `EXE_SRA_OP;
                        alusel_out = `EXE_RES_SHIFT;
                        reg_rd_en1_out = 0;
                        reg_rd_en2_out = 1;
                        reg_wr_en_out  = 1;
                        reg_rd_addr1_out = rs;
                        reg_rd_addr2_out = rt;
                        reg_wr_addr_out = wt;
                        imm_data = {27'h0,op4};
                        inst_valid = 1;
                    end
                    default:  begin
                        aluop_out = `EXE_NOP_OP;
                        alusel_out = `EXE_RES_LOGIC;
                        reg_rd_en1_out = 0;
                        reg_rd_en2_out = 0;
                        reg_wr_en_out  = 0;
                        reg_rd_addr1_out = rs;
                        reg_wr_addr_out = rt;
                        inst_valid = 1;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        if(!rst_n) begin
            reg_rd_data1_out = 0;
        end else if (reg_rd_en1_out && ex_wen_in && reg_rd_addr1_out == ex_waddr_in) begin
            reg_rd_data1_out = ex_wdata_in;
        end else if (reg_rd_en1_out && ex_wen_in && reg_rd_addr1_out == mem_waddr_in) begin
            reg_rd_data1_out = mem_wdata_in;
        end else if(reg_rd_en1_out == 1) begin
            reg_rd_data1_out = reg_rd_data1_in; //id process, read from regs
        end else if(reg_rd_en1_out == 0) begin
            reg_rd_data1_out = imm_data;
        end else begin
            reg_rd_data1_out = 0;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            reg_rd_data2_out = 0;
        end else if (reg_rd_en2_out && ex_wen_in && reg_rd_addr2_out == ex_waddr_in) begin
            reg_rd_data2_out = ex_wdata_in;
        end else if (reg_rd_en2_out && mem_wen_in && reg_rd_addr2_out == mem_waddr_in) begin
            reg_rd_data2_out = mem_wdata_in;
        end else if(reg_rd_en2_out == 1) begin
            reg_rd_data2_out = reg_rd_data2_in;
        end else if(reg_rd_en2_out == 0) begin
            reg_rd_data2_out = imm_data;
        end else begin
            reg_rd_data2_out = 0;
        end
    end

endmodule