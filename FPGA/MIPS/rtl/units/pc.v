module pc (
    input                        clk,
    input                        rst_n,//sync reset
    input[`CTRL_WIDTH-1:0]                   stall,

    output reg[`INST_ADDR_WIDTH-1:0] addr_to_rom,
    output reg                       pc_enable
);

    always @(posedge clk) begin
        if(!rst_n) begin
            pc_enable <= 1'b0;
        end else begin
            pc_enable <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(!pc_enable) begin
            addr_to_rom <= 0; //one pipe delay
        end else if(stall[0] == 0) begin
            addr_to_rom <= addr_to_rom + 'd4;
        end
    end

endmodule