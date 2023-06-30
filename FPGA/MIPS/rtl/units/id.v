module id (
    input                        rst_n,//sync rst, low valid
    input[`INST_DATA_WIDTH-1:0]  inst_data_in,

    input[`REG_DATA_WIDTH-1:0]   reg_rd_data1_in,
    input[`REG_DATA_WIDTH-1:0]   reg_rd_data2_in,
    
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
    wire[6-1:0]  op = inst_data_in[31:26];
    wire[4:0]    rs = inst_data_in[25:21];
    wire[4:0]    rt = inst_data_in[20:16];
    wire[4:0]    wt = inst_data_in[15:11];
    wire[16-1:0] im = inst_data_in[15:0];


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
        end else begin
            aluop_out = `EXE_NOP;
            alusel_out = `EXE_RES_NOP;
            inst_valid = 1;
            reg_rd_addr1_out = rs;
            reg_rd_addr2_out = rt;
            reg_wr_addr_out = wt; //why
            reg_rd_en1_out = 0;
            reg_rd_en2_out = 0;
            reg_wr_en_out = 0;

            case (op)
                `EXE_ORI: begin
                    aluop_out = `EXE_OP_OR;
                    alusel_out = `EXE_RES_LOGIC;
                    reg_rd_en1_out = 1;
                    reg_rd_en2_out = 0;
                    reg_wr_en_out  = 1£»
                    reg_rd_addr1_out = rs;
                    reg_wr_addr_out = rt;
                    imm_data = {16'h0,im};
                    inst_valid = 1;
                end
                default: begin
                    
                end
            endcase
        end
    end

    always @(*) begin
        if(!rst_n) begin
            reg_rd_data1_out = 0;
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
        end else if(reg_rd_en2_out == 1) begin
            reg_rd_data2_out = reg_rd_data2_in;
        end else if(reg_rd_en2_out == 0) begin
            reg_rd_data2_out = imm_data;
        end else begin
            reg_rd_data2_out = 0;
        end
    end

endmodule