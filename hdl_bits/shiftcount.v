module top_module (
    input clk,
    input shift_ena,
    input count_ena,
    input data,
    output [3:0] q);

    reg [3:0] q_r;
    assign q = q_r;

    always @(posedge clk ) begin
        if(shift_ena) begin
            q_r <= {q_r[2:0],data};
        end else if(count_ena) begin
            q_r <= q_r - 1'b1;
        end
    end

endmodule
