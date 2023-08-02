module ctrl (
    input            rst_n,
    input            stall_req_id,
    input            stall_req_ex,

    output reg[`CTRL_WIDTH-1:0]  stall
);
//stall 0-5 bits represent pc if id ex mem wb
    always @(*) begin
        if(!rst_n) begin
            stall = 6'h0;
        end else if (stall_req_ex == 1) begin
            stall = 6'b00_1111;
        end else if (stall_req_id == 1) begin
            stall = 6'b00_0111;
        end else begin
            stall = 6'h0;
        end
    end
    
endmodule