`timescale 1ns/1ps
module soc_tb();

 //reg define
 reg sys_clk ;
 reg sys_rst_n ;
 
 //********************************************************************//
 //***************************** Main Code ****************************//
 //********************************************************************//
 
    initial begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #200
        sys_rst_n <= 1'b1;
    end

    initial begin
        #2000 $finish();
    end

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
    end

    always #10 sys_clk = ~sys_clk;
       
    mips u_mips(
        .clk(sys_clk),
        .rst_n(sys_rst_n)	
    );

endmodule