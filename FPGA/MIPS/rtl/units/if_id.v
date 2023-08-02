module if_id (
    input                            clk,
    input                            rst_n,
    input[`CTRL_WIDTH-1:0]           stall,
    input[`INST_DATA_WIDTH-1:0]      inst_in,
    output reg[`INST_DATA_WIDTH-1:0] inst_out 
);

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_out <= 0;
        end else if(stall[1] == 1 && stall[2] == 0) begin //if stop but id run, send nop cmd
            inst_out <= 0;
        end else if(stall[1] == 0) begin
            inst_out <= inst_in;
        end //other case, hold inst_out
    end
endmodule