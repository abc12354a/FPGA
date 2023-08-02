//********************** COMMON **********************
`define REG_NUM         32
`define INST_NUM        1024
`define INST_NUM_LOG2   10
//********************** WIDTH **********************
`define INST_ADDR_WIDTH 32
`define INST_DATA_WIDTH 32
`define REG_ADDR_WIDTH  5
`define REG_DATA_WIDTH  32
`define ALUSEL_WIDTH    3
`define ALUOP_WIDTH     8
`define CTRL_WIDTH      6
//********************** INST **********************
`define EXE_ORI   6'b001101
`define EXE_NOP   6'b000000
`define EXE_AND   6'b100100
`define EXE_OR    6'b100101
`define EXE_XOR   6'b100110
`define EXE_NOR   6'b100111
`define EXE_ANDI  6'b001100
`define EXE_XORI  6'b001110
`define EXE_LUI   6'b001111

`define EXE_SLL   6'b000000
`define EXE_SRL   6'b000010
`define EXE_SRA   6'b000011
`define EXE_SLLV  6'b000100
`define EXE_SRLV  6'b000110
`define EXE_SRAV  6'b000111

`define EXE_MOVZ  6'b001010
`define EXE_MOVN  6'b001011
`define EXE_MFHI  6'b010000
`define EXE_MTHI  6'b010001
`define EXE_MFLO  6'b010010
`define EXE_MTLO  6'b010011

`define EXE_SLT   6'b101010
`define EXE_SLTU  6'b101011
`define EXE_SLTI  6'b001010
`define EXE_SLTIU 6'b001011   
`define EXE_ADD   6'b100000
`define EXE_ADDU  6'b100001
`define EXE_SUB   6'b100010
`define EXE_SUBU  6'b100011
`define EXE_ADDI  6'b001000
`define EXE_ADDIU 6'b001001
`define EXE_CLZ   6'b100000
`define EXE_CLO   6'b100001


`define EXE_MULT  6'b011000
`define EXE_MULTU 6'b011001
`define EXE_MUL   6'b000010
`define EXE_MADD  6'b000000
`define EXE_MADDU 6'b000001
`define EXE_MSUB  6'b000100
`define EXE_MSUBU 6'b000101

`define EXE_SYNC  6'b001111
`define EXE_PREF  6'b110011

//******************** R_OP **********************
`define EXE_SPEC  6'b000000
`define EXE_SPEC2 6'b011100
//********************** OP **********************
`define EXE_AND_OP    8'b0010_0100
`define EXE_OR_OP     8'b0010_0101
`define EXE_XOR_OP    8'b0010_0110
`define EXE_NOR_OP    8'b0010_0111
`define EXE_ANDI_OP   8'b0101_1001
`define EXE_ORI_OP    8'b0101_1010
`define EXE_XORI_OP   8'b0101_1011
`define EXE_LUI_OP    8'b0101_1100   

`define EXE_SLL_OP    8'b0111_1100
`define EXE_SLLV_OP   8'b0000_0100
`define EXE_SRL_OP    8'b0000_0010
`define EXE_SRLV_OP   8'b0000_0110
`define EXE_SRA_OP    8'b0000_0011
`define EXE_SRAV_OP   8'b0000_0111

`define EXE_MOVZ_OP   8'b0000_1010
`define EXE_MOVN_OP   8'b0000_1011
`define EXE_MFHI_OP   8'b0001_0000
`define EXE_MTHI_OP   8'b0001_0001
`define EXE_MFLO_OP   8'b0001_0010
`define EXE_MTLO_OP   8'b0001_0011

`define EXE_SLT_OP    8'b0010_1010
`define EXE_SLTU_OP   8'b0010_1011
`define EXE_SLTI_OP   8'b0101_0111
`define EXE_SLTIU_OP  8'b0101_1000   
`define EXE_ADD_OP    8'b0010_0000
`define EXE_ADDU_OP   8'b0010_0001
`define EXE_SUB_OP    8'b0010_0010
`define EXE_SUBU_OP   8'b0010_0011
`define EXE_ADDI_OP   8'b0101_0101
`define EXE_ADDIU_OP  8'b0101_0110
`define EXE_CLZ_OP    8'b1011_0000
`define EXE_CLO_OP    8'b1011_0001

`define EXE_MULT_OP   8'b0001_1000
`define EXE_MULTU_OP  8'b0001_1001
`define EXE_MUL_OP    8'b1010_1001
`define EXE_MADD_OP   8'b1010_0110
`define EXE_MADDU_OP  8'b1010_1000
`define EXE_MSUB_OP   8'b1010_1010
`define EXE_MSUBU_OP  8'b1010_1011

`define EXE_NOP_OP    8'b0000_0000
//********************** SEL **********************
`define EXE_RES_LOGIC      3'b001
`define EXE_RES_NOP        3'b000
`define EXE_RES_SHIFT      3'b010
`define EXE_RES_MOVE       3'b011
`define EXE_RES_ARITHMETIC 3'b100	
`define EXE_RES_MUL        3'b101