module hilo_regs (
    input                           clk,
    input                           rst_n,
    input                           we,
    input[`REG_DATA_WIDTH-1:0]      hi_data_in,
    input[`REG_DATA_WIDTH-1:0]      lo_data_in,

    output reg[`REG_DATA_WIDTH-1:0] hi_data_out,
    output reg[`REG_DATA_WIDTH-1:0] lo_data_out
);

    always @(posedge clk) begin
        if(!rst_n) begin
            hi_data_out <= 'b0;
            lo_data_out <= 'b0;
        end else if(we) begin
            hi_data_out <= hi_data_in;
            lo_data_out <= lo_data_in;
        end
    end
    
endmodule