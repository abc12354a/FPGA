`include "defines.v"
`timescale 1ns/1ps

module soc_tb();

  reg     CLOCK_50;
  reg     rst_n;
  
       
  initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
  end
      
  initial begin
    rst_n = 0;
    #195 rst_n= 1;
    #1000 $stop;
  end
       
  soc_top u_soc_top(
		.clk(CLOCK_50),
		.rst_n(rst_n)	
	);

endmodule