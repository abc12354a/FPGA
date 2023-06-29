module inst_rom(
	input                               ce,
	input     [`INST_ADDR_WIDTH-1:0]    addr,
	output reg[`INST_DATA_WIDTH-1:0]    inst
);

	reg[`INST_DATA_WIDTH-1:0]  inst_mem[`INST_NUM-1:0];

	initial $readmemh ( "inst_rom.data", inst_mem );

/*       ________________
   0x4  |___|___|___|___| mem[1]  0x4=0100  <=> 1, right shift 2bits. 
                 10bits addres => 1024bits data
*/

	always @ (*) begin
        if (ce == 0) begin
            inst = 0;
        end else begin
            inst = inst_mem[addr[`INST_NUM_LOG2+1:2]];
        end
	end

endmodule