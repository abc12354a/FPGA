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

    output reg[`REG_ADDR_WIDTH-1:0] w_reg_addr_out,
    output reg[`REG_DATA_WIDTH-1:0] w_reg_data_out,
    output reg                      w_reg_en_out,

    output reg[`REG_DATA_WIDTH-1:0] hi_regs_out,
    output reg[`REG_DATA_WIDTH-1:0] lo_regs_out,
    output reg                      hilo_wen
);
    reg[`REG_DATA_WIDTH-1:0]    logic_res;
    reg[`REG_DATA_WIDTH-1:0]    shift_res;
    reg[`REG_DATA_WIDTH-1:0]    move_res;
    reg[`REG_DATA_WIDTH-1:0]    arith_res;
    reg[`REG_DATA_WIDTH-1:0]    reg_hi;
    reg[`REG_DATA_WIDTH-1:0]    reg_lo;
    
    wire                        over_mem;
    wire                        reg1_eq_reg2;
    wire                        reg1_lt_reg2; //reg1 < reg2
    wire[`REG_DATA_WIDTH-1:0]   reg2_mux;
    wire[`REG_DATA_WIDTH-1:0]   reg1_not;
    wire[`REG_DATA_WIDTH-1:0]   sum_res;
    wire[`REG_DATA_WIDTH-1:0]   mul_op1;
    wire[`REG_DATA_WIDTH-1:0]   mul_op2;
    wire[64-1:0]               hilo_tmp;
    reg[64-1:0]                 mul_res;

    assign reg2_mux = 


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
                default: begin
                    hi_regs_out = 0;
                    lo_regs_out = 0;
                    hilo_wen = 0;
                end
            endcase
        end
    end
    
    always @(*) begin
        w_reg_addr_out = w_reg_addr_in;
        w_reg_en_out   = w_reg_en_in;
        case (alusel_in)
            `EXE_RES_LOGIC: w_reg_data_out = logic_res; //combination logic
            `EXE_RES_SHIFT: w_reg_data_out = shift_res; 
            `EXE_RES_MOVE:  w_reg_data_out = move_res;
            default: w_reg_data_out = 0;
        endcase
    end
    
endmodule