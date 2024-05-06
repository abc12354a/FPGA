module fsm_tb();
    reg  sys_clk;
    reg  sys_rst_n;
    reg  pay;
    wire coke;

    initial begin
        forever begin
            #10 sys_clk <= ~sys_clk;
        end
    end

    initial begin
        #2000 $finish();
    end

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        sys_rst_n <= 0;
        #50 sys_rst_n <= 1;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            pay <= 0;
        end else begin
            pay <= ($random) % 2;
        end
    end

    fsm u_fsm(
        sys_clk,
        sys_rst_n,
        pay,
        coke
    );
endmodule