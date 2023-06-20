module top_module (
    input clk,
    input reset,
    output [9:0] q);

    reg [9:0] q_r;
    assign q = q_r;
    always @(posedge clk ) begin
        if(reset) begin
            q_r <= 0;
        end else begin
            if(q_r >= 999) begin
                q_r <= 0;
            end else begin
                q_r <= q_r + 1;
            end 
        end
    end
endmodule