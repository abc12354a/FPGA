module mips (
    input                         clk,
    input                         rst_n
);

    wire[`INST_ADDR_WIDTH-1:0] inst_addr;
    wire[`INST_DATA_WIDTH-1:0] inst_data;
    wire                       rom_enable;

    mips_top u_mips_top(
        .clk(clk),
        .rst_n(rst_n),
        .rom_data_in(inst_data),
        .rom_addr_out(inst_addr),
        .rom_enable(rom_enable)
    );

    inst_rom u_inst_rom(
        .ce(rom_enable),
        .addr(inst_addr),
        .inst(inst_data)
    );
    
endmodule