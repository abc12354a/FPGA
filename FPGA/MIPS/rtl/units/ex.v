module ex (
    input                           rst_n,//async rst?
    input[`ALUSEL_WIDTH-1:0]        alusel_in,
    input[`ALUOP_WIDTH-1:0]         aluop_in,
    input[`REG_DATA_WIDTH-1:0]      reg1_in,
    input[`REG_DATA_WIDTH-1:0]      reg2_in,
    input[`REG_ADDR_WIDTH-1:0]      w_reg_addr_in,
    input                           w_reg_en_in,

    input[`REG_DATA_WIDTH-1:0]      hi_regs_in,
    input[`REG_DATA_WIDTH-1:0]      lo_regs_in,
    
    input[`REG_DATA_WIDTH-1:0]      wb_hi_regs_in,
    input[`REG_DATA_WIDTH-1:0]      wb_lo_regs_in,
    input                           wb_hilo_wen,

    input[`REG_DATA_WIDTH-1:0]      mem_hi_regs_in,
    input[`REG_DATA_WIDTH-1:0]      mem_lo_regs_in,
    input                           mem_hilo_wen,

    input[64-1:0]                   hilo_tmp_in,
    input[1:0]                      mul_cnt_in,

    output reg                      stall_req,
    output reg[`REG_ADDR_WIDTH-1:0] w_reg_addr_out,
    output reg[`REG_DATA_WIDTH-1:0] w_reg_data_out,
    output reg                      w_reg_en_out,
    output reg[64-1:0]              hilo_tmp_out,
    output reg[1:0]                 mul_cnt_out,
    output reg[`REG_DATA_WIDTH-1:0] hi_regs_out,
    output reg[`REG_DATA_WIDTH-1:0] lo_regs_out,
    output reg                      hilo_wen
);
    reg[`REG_DATA_WIDTH-1:0]    logic_res;
    reg[`REG_DATA_WIDTH-1:0]    shift_res;
    reg[`REG_DATA_WIDTH-1:0]    move_res;
    reg[`REG_DATA_WIDTH-1:0]    arith_res;
    reg[64-1:0]                 mul_res;
    reg[`REG_DATA_WIDTH-1:0]    reg_hi;
    reg[`REG_DATA_WIDTH-1:0]    reg_lo;
    
    reg[64-1:0]                 hilo_tmp_ma_inst;
    reg                         stall_req_ma_inst;

    wire                        over_mem;
    wire                        reg1_eq_reg2;
    wire                        reg1_lt_reg2; //reg1 < reg2
    wire[`REG_DATA_WIDTH-1:0]   reg2_mux;
    wire[`REG_DATA_WIDTH-1:0]   reg1_not;
    wire[`REG_DATA_WIDTH-1:0]   sum_res;
    wire[`REG_DATA_WIDTH-1:0]   mul_op1;
    wire[`REG_DATA_WIDTH-1:0]   mul_op2;
    wire[64-1:0]                hilo_tmp;
    

    assign reg2_mux = ((aluop_in == `EXE_SUB_OP )||
                       (aluop_in == `EXE_SUBU_OP)||
                       (aluop_in == `EXE_SLT_OP)) ? (~reg2_in)+1 : reg2_in;
    
    assign reg1_not = ~reg1_in;

    assign sum_res  = reg1_in + reg2_mux;

    assign over_mem = (!reg1_in[31] && !reg2_mux[31] && sum_res[31])||
                      ( reg1_in[31] &&  reg2_mux[31] && !sum_res[31]);

    assign reg1_lt_reg2 = (aluop_in == `EXE_SLT_OP)?
                          ( reg1_in[31] && !reg2_in[31])|| 
                          ( reg1_in[31] &&  reg2_in[31] &&  sum_res[31])||
                          (!reg1_in[31] && !reg2_in[31] &&  sum_res[31]):
                          (reg1_in < reg2_in);

    assign mul_op1  = ((aluop_in == `EXE_MUL_OP) || (aluop_in == `EXE_MULT_OP)
                      ||(aluop_in == `EXE_MADD_OP)||(aluop_in == `EXE_MSUB_OP))&&reg1_in[31] ?
                      (~reg1_in + 1) : reg1_in;
    
    assign mul_op2  = ((aluop_in == `EXE_MUL_OP) || (aluop_in == `EXE_MULT_OP)
                      ||(aluop_in == `EXE_MADD_OP)||(aluop_in == `EXE_MSUB_OP))&&reg2_in[31] ?
                      (~reg2_in + 1) : reg2_in;

    assign hilo_tmp =  mul_op1*mul_op2;                  

    always @(*) begin
        if(!rst_n)begin
            reg_hi = 0;
            reg_lo = 0;
        end else if(mem_hilo_wen) begin
            reg_hi = mem_hi_regs_in;
            reg_lo = mem_lo_regs_in;
        end else if(wb_hilo_wen) begin
            reg_hi = wb_hi_regs_in;
            reg_lo = wb_lo_regs_in;
        end else begin
            reg_hi = hi_regs_in;
            reg_lo = lo_regs_in;
        end
    end

    always @(*) begin
        stall_req = stall_req_ma_inst;
    end

    always @(*) begin
        if(!rst_n)begin
            mul_res = 0;
        end else begin
            case (aluop_in)
                `EXE_MUL_OP, `EXE_MULT_OP ,`EXE_MADD_OP,`EXE_MSUB_OP: begin
                    if (reg1_in[31] ^ reg2_in[31]) begin
                        mul_res = ~hilo_tmp + 1;
                    end else begin
                        mul_res = hilo_tmp;
                    end
                end
                default: mul_res = hilo_tmp;
            endcase
        end
    end

    always @(*) begin
        if(!rst_n) begin
            hilo_tmp_out = 0;
            mul_cnt_out = 0;
            stall_req_ma_inst = 0;
        end else begin
            case (aluop_in)
                `EXE_MADD_OP, `EXE_MADDU_OP: begin
                    if(mul_cnt_in == 'b0) begin
                        hilo_tmp_out = mul_res;
                        mul_cnt_out = 2'b01;
                        hilo_tmp_ma_inst = 'b0;
                        stall_req_ma_inst = 'b1;
                    end else if(mul_cnt_in == 'b01) begin
                        hilo_tmp_out = 'b0;
                        mul_cnt_out = 2'b10;
                        hilo_tmp_ma_inst = hilo_tmp_in + {reg_hi,reg_lo};
                        stall_req_ma_inst = 'b0;
                    end else begin
                        hilo_tmp_out = 0;
                        mul_cnt_out = 2'b0;
                        hilo_tmp_ma_inst = 'b0;
                        stall_req_ma_inst = 'b0;
                    end
                end
                `EXE_MSUB_OP, `EXE_MSUBU_OP: begin
                    if(mul_cnt_in == 'b0) begin
                        hilo_tmp_out = ~mul_res+1;
                        mul_cnt_out = 2'b01;
                        hilo_tmp_ma_inst = 'b0;
                        stall_req_ma_inst = 'b1;
                    end else if(mul_cnt_in == 'b01) begin
                        hilo_tmp_out = 'b0;
                        mul_cnt_out = 2'b10;
                        hilo_tmp_ma_inst = hilo_tmp_in + {reg_hi,reg_lo};
                        stall_req_ma_inst = 'b0;
                    end else begin
                        hilo_tmp_out = 0;
                        mul_cnt_out = 2'b0;
                        hilo_tmp_ma_inst = 'b0;
                        stall_req_ma_inst = 'b0;
                    end
                end 
                default: begin
                    hilo_tmp_out = 0;
                    mul_cnt_out = 0;
                    stall_req_ma_inst = 0;
                end
            endcase
        end
    end

    always @(*) begin
        if(!rst_n)begin
            logic_res = 0;
        end else begin
            case (aluop_in)
                `EXE_OR_OP: logic_res = reg1_in | reg2_in;
                `EXE_AND_OP:logic_res = reg1_in & reg2_in;
                `EXE_NOR_OP:logic_res = ~(reg1_in | reg2_in);
                `EXE_XOR_OP:logic_res = reg1_in ^ reg2_in;
                default: logic_res = 0;
            endcase
        end
    end

    always @(*) begin
        if(!rst_n)begin
            arith_res = 0;
        end else begin
            case(aluop_in) 
                `EXE_SLT_OP, `EXE_SLTU_OP: arith_res = reg1_lt_reg2;
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: arith_res = sum_res;
                `EXE_SUB_OP, `EXE_SUBU_OP: arith_res = sum_res;
                `EXE_CLZ_OP: begin
                    arith_res = reg1_in[31] ? 'd0  : reg1_in[30]  ? 'd1  : reg1_in[29] ? 'd2  :
                                reg1_in[28] ? 'd3  : reg1_in[27]  ? 'd4  : reg1_in[26] ? 'd5  :
                                reg1_in[25] ? 'd6  : reg1_in[24]  ? 'd7  : reg1_in[23] ? 'd8  : 
                                reg1_in[22] ? 'd9  : reg1_in[21]  ? 'd10 : reg1_in[20] ? 'd11 :
                                reg1_in[19] ? 'd12 : reg1_in[18] ? 'd13  : reg1_in[17] ? 'd14 : 
                                reg1_in[16] ? 'd15 : reg1_in[15] ? 'd16  : reg1_in[14] ? 'd17 : 
                                reg1_in[13] ? 'd18 : reg1_in[12] ? 'd19  : reg1_in[11] ? 'd20 :
                                reg1_in[10] ? 'd21 : reg1_in[9]  ? 'd22  : reg1_in[8]  ? 'd23 : 
                                reg1_in[7]  ? 'd24 : reg1_in[6]  ? 'd25  : reg1_in[5]  ? 'd26 : 
                                reg1_in[4]  ? 'd27 : reg1_in[3]  ? 'd28  : reg1_in[2]  ? 'd29 : 
                                reg1_in[1]  ? 'd30 : reg1_in[0]  ? 'd31  : 'd32 ;
                end
                `EXE_CLO_OP: begin
                    arith_res = reg1_not[31]  ? 'd0  : reg1_not[30] ? 'd1  : reg1_not[29] ? 'd2  :
                                reg1_not[28]  ? 'd3  : reg1_not[27] ? 'd4  : reg1_not[26] ? 'd5  :
                                reg1_not[25]  ? 'd6  : reg1_not[24] ? 'd7  : reg1_not[23] ? 'd8  : 
                                reg1_not[22]  ? 'd9  : reg1_not[21] ? 'd10 : reg1_not[20] ? 'd11 :
                                reg1_not[19]  ? 'd12 : reg1_not[18] ? 'd13 : reg1_not[17] ? 'd14 : 
                                reg1_not[16]  ? 'd15 : reg1_not[15] ? 'd16 : reg1_not[14] ? 'd17 : 
                                reg1_not[13]  ? 'd18 : reg1_not[12] ? 'd19 : reg1_not[11] ? 'd20 :
                                reg1_not[10]  ? 'd21 : reg1_not[9]  ? 'd22 : reg1_not[8]  ? 'd23 : 
                                reg1_not[7]   ? 'd24 : reg1_not[6]  ? 'd25 : reg1_not[5]  ? 'd26 : 
                                reg1_not[4]   ? 'd27 : reg1_not[3]  ? 'd28 : reg1_not[2]  ? 'd29 : 
                                reg1_not[1]   ? 'd30 : reg1_not[0]  ? 'd31 : 'd32 ;
                end
                default: arith_res = 0;
            endcase
        end
    end

    always @(*) begin
        if(!rst_n)begin
            shift_res = 0;
        end else begin
            case (aluop_in)
                `EXE_SLL_OP:shift_res = reg2_in << reg1_in[4:0];
                `EXE_SRL_OP:shift_res = reg2_in >> reg1_in[4:0];
                `EXE_SRA_OP:shift_res = ({32{reg2_in[31]}} << (6'd32-{1'b0,reg1_in[4:0]}))| reg2_in >> reg1_in[4:0];
                default: shift_res = 0;
            endcase
        end
    end

    always @(*) begin
        if(!rst_n)begin
            move_res = 0;
        end else begin
            case (aluop_in)
                `EXE_MOVZ_OP:move_res = reg1_in;
                `EXE_MOVN_OP:move_res = reg1_in;
                `EXE_MFHI_OP:move_res = reg_hi;
                `EXE_MFLO_OP:move_res = reg_lo;
                default: move_res = 0;
            endcase
        end
    end

    always @(*) begin
        if(!rst_n)begin
            hi_regs_out = 0;
            lo_regs_out = 0;
            hilo_wen = 0;
        end else begin
            case (aluop_in)
                `EXE_MTHI_OP:begin
                    hi_regs_out = reg1_in;
                    lo_regs_out = 0;
                    hilo_wen = 1;
                end
                `EXE_MTLO_OP:begin
                    hi_regs_out = 0;
                    lo_regs_out = reg1_in;
                    hilo_wen = 1;
                end
                `EXE_MULT_OP, `EXE_MULTU_OP: begin
                    hi_regs_out = mul_res[63:32];
                    lo_regs_out = mul_res[31:0];
                    hilo_wen = 1;
                end
                `EXE_MADD_OP, `EXE_MADDU_OP: begin
                    hi_regs_out = hilo_tmp_ma_inst[63:32];
                    lo_regs_out = hilo_tmp_ma_inst[31:0];
                    hilo_wen = 1;
                end
                `EXE_MSUB_OP, `EXE_MSUBU_OP: begin
                    hi_regs_out = hilo_tmp_ma_inst[63:32];
                    lo_regs_out = hilo_tmp_ma_inst[31:0];
                    hilo_wen = 1;
                end
                default: begin
                    hi_regs_out = 0;
                    lo_regs_out = 0;
                    hilo_wen = 0;
                end
            endcase
        end
    end
    
    always @(*) begin
        if((aluop_in == `EXE_ADD_OP || aluop_in == `EXE_ADDI_OP || aluop_in == `EXE_SUB_OP)&&over_mem) begin
            w_reg_en_out = 0;
        end else begin
            w_reg_en_out   = w_reg_en_in;
        end
        w_reg_addr_out = w_reg_addr_in;
        case (alusel_in)
            `EXE_RES_LOGIC:       w_reg_data_out = logic_res; //combination logic
            `EXE_RES_SHIFT:       w_reg_data_out = shift_res; 
            `EXE_RES_MOVE:        w_reg_data_out = move_res;
            `EXE_RES_MUL:         w_reg_data_out = mul_res[31:0];
            `EXE_RES_ARITHMETIC:  w_reg_data_out = arith_res;
            default: w_reg_data_out = 0;
        endcase
    end
    
endmodule