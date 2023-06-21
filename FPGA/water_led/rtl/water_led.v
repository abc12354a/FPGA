module water_led (
    input sys_clk,
    input sys_rst_n,

    output[3:0] led_out
);
parameter CNT_MAX = 25'd24_999_999;
reg [3:0] led_out_r;
reg [24:0] counter;
reg cnt_flag;
assign led_out = led_out_r;

always @(posedge sys_clk ) begin
    if(!sys_rst_n) begin
        counter <= 0;
    end else if(counter < CNT_MAX) begin
        counter <= counter+1;
    end else begin
        counter <= 0;
       
    end
end

always @(posedge sys_clk ) begin
    if(!sys_rst_n) begin
        cnt_flag <= 0;
    end else if(counter == CNT_MAX) begin
        cnt_flag <= 1;
    end else begin
        cnt_flag <= 0;
    end
end


always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        led_out_r <= 4'b0001;
    end else if(cnt_flag) begin
        if(led_out_r == 4'b1000) begin
            led_out_r <= 4'b0001;
        end else begin
            led_out_r <= led_out_r << 1'b1;
        end
    end
end

    
endmodule