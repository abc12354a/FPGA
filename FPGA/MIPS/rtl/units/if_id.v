module if_id (
    input                        clk,
    input                        rst_n,
    input[`INST_DATA_WIDTH-1:0]  inst_in,
    output[`INST_DATA_WIDTH-1:0] inst_out 
);

    always @(posedge clk) begin
        if(!rst_n) begin
            inst_out <= 0;
        end else begin
            inst_out <= inst_in;
        end
    end
endmodule