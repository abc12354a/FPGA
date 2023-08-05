module div (
    input                                   clk,
    input                                   rst_n,
    input                                   signed_div_in,
    input[`REG_DATA_WIDTH-1:0]              dived_in,
    input[`REG_DATA_WIDTH-1:0]              div_in,
    input                                   div_start_in,
    input                                   div_cancel_in,
    output reg[`DOUBLE_DATA_WIDTH-1:0]      div_res_out,
    output reg                              div_ready_out,
);
    
endmodule