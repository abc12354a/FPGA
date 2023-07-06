module ex (
    input                       rst_n,//async rst?
    input[`ALUSEL_WIDTH-1:0]    alusel_in,
    input[`ALUOP_WIDTH-1:0]     aluop_in,
    input[`REG_DATA_WIDTH-1:0]  reg1_in,
    input[`REG_DATA_WIDTH-1:0]  reg2_in,
    input[`REG_ADDR_WIDTH-1:0]  w_reg_addr_in,
    input                       w_reg_en_in,

    output reg[`REG_ADDR_WIDTH-1:0] w_reg_addr_out,
    output reg[`REG_DATA_WIDTH-1:0] w_reg_data_out,
    output reg                      w_reg_en_out
);
    reg[`REG_DATA_WIDTH-1:0]    logic_out;
    reg[`REG_DATA_WIDTH-1:0]    shift_res;
    always @(*) begin
        if(!rst_n)begin
            logic_out = 0;
        end else begin
            case (aluop_in)
                `EXE_OR_OP: logic_out = reg1_in | reg2_in;
                `EXE_AND_OP:logic_out = reg1_in & reg2_in;
                `EXE_NOR_OP:logic_out = ~(reg1_in | reg2_in);
                `EXE_XOR_OP:logic_out = reg1_in ^ reg2_in;
                default: logic_out = 0;
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
                `EXE_SRA_OP:shift_res = ({32{reg2_in[31]}} << (6'd32-{'b0,reg1_in[4:0]}))| reg2_in >> reg1_in[4:0];
                default: shift_res = 0;
            endcase
        end
    end
    
    always @(*) begin
        w_reg_addr_out = w_reg_addr_in;
        w_reg_en_out   = w_reg_en_in;
        case (alusel_in)
            `EXE_RES_LOGIC: w_reg_data_out = logic_out; //combination logic
            `EXE_RES_SHIFT: w_reg_data_out = shift_res; 
            default: w_reg_data_out = 0;
        endcase
    end
    
endmodule