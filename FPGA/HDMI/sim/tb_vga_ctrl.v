module tb_vga_ctrl();
    reg  sys_clk;
    reg  sys_rst_n;
    reg  [15:0]pix_data;
    reg  [9:0] pix_x;
    reg  [9:0] pix_y;
    reg  hsync;
    reg  vsync;
    reg  [15:0] rgb;
    initial begin
        sys_clk <= 0;
        forever begin
            #10 sys_clk <= ~sys_clk;
        end
    end

    initial begin
        sys_rst_n <= 0;
        #50 sys_rst_n <= 1;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n)
            pix_data <= 0;
        else
            pix_data <= 16'hffff;
    end

    vga_ctrl u_vga_ctrl(
        sys_clk,
        sys_rst_n,
        pix_data,
        pix_x,
        pix_y,
        hsync,
        vsync,
        rgb
    )

    initial begin
        #2000 $finish();
    end

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
    end
endmodule