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
//********************** INST **********************
`define EXE_ORI 6'b001101
`define EXE_NOP 6'b000000

//********************** OP **********************
`define EXE_OP_OR     8'b00100101
`define EXE_OP_NOP    8'b00000000

//********************** SEL **********************
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_NOP   3'b000