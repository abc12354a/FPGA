`timescale 1ns/1ps
module soc_tb();

 //reg define
 reg sys_clk ;
 reg sys_rst_n ;
 
 //********************************************************************//
 //***************************** Main Code ****************************//
 //********************************************************************//
 //初始化系统时钟、全局复位
    initial begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #200
        sys_rst_n <= 1'b1;
    end

    initial begin
        #500 $finish();
    end
 
 //sys_clk:模拟系统时钟，每 10ns 电平翻转一次，周期为 20ns，频率为 50Mhz
    always #10 sys_clk = ~sys_clk;
       
    mips u_mips(
        .clk(sys_clk),
        .rst_n(sys_rst_n)	
    );

endmodule