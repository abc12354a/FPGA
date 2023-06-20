module top_module (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output start_shifting);

    reg start_shifting_r;
    assign start_shifting = start_shifting_r;
    reg[3:0] shift_fifo;
    always@(posedge clk) begin
        if(reset == 1) begin
            start_shifting_r <= 0;
            shift_fifo <=0;
        end else begin
            shift_fifo <= {shift_fifo[2:0],data};
            if((shift_fifo == 4'b0110 || shift_fifo == 4'b1110 )&& data==1) begin
                start_shifting_r <= 1;
            end
        end
    end

    // always@(posedge clk) begin
    //     shift_fifo <= {shift_fifo[2:0],data};
    // end

endmodule