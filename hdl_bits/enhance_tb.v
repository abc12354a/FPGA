module fsm_tb();
    reg  sys_clk;
    reg  sys_rst_n;
    reg  pay;
    reg  pay_half;
    reg  data_gen;
    wire coke;
    wire ret;

    initial begin
        forever begin
            #10 sys_clk <= ~sys_clk;
        end
    end

    initial begin
        sys_rst_n <= 0;
        #50 sys_rst_n <= 1;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            data_gen <= 0;
            // pay_half <= 0;
        end else begin
            data_gen <= ($random) % 2;
            // pay_half <= 
        end
    end
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            pay <= 0;
            pay_half <= 0;
        end else begin
            pay <= data_gen;
            pay_half <= ~data_gen;
        end
    end

    enhance_fsm u_enhance_fsm(
        sys_clk,
        sys_rst_n,
        pay,
        pay_half,
        ret,
        coke
    );
endmodule