module regs (
    input                        clk,
    input                        rst_n,
    input[`REG_ADDR_WIDTH-1:0]   waddr,
    input[`REG_DATA_WIDTH-1:0]   wdata,
    input[`REG_ADDR_WIDTH-1:0]   raddr1,
    input[`REG_ADDR_WIDTH-1:0]   raddr2,
    input                        we,
    input                        re1,
    input                        re2,

    output[`REG_DATA_WIDTH-1:0]  rdata1,
    output[`REG_DATA_WIDTH-1:0]  rdata2
);
    reg[`REG_DATA_WIDTH-1:0] regs[`REG_NUM-1:0]; //32 regs

//********************** write operation **********************
    always @(posedge clk) begin
        if(rst_n) begin
            if(we && waddr!=0)begin// reg0 stands for null
                regs[waddr] <= wdata;
            end 
        end
    end

//********************** read operation **********************
    always @(*) begin //read operation doesn't require clk
        if(!rst_n) begin
            rdata1 <= 0;
        end else if(raddr1 == 'b0) begin
            rdata1 <= 0;
        end else begin
            if(re1 && we && raddr1 == waddr) begin //write && read same time
                rdata1 <= wdata;
            end else if(re1)begin
                rdata1 <= regs[raddr1];
            end else begin
                rdata1 <= 0;
            end
        end
    end

    always @(*) begin //read operation doesn't require clk
        if(!rst_n) begin
            rdata2 <= 0;
        end else if(raddr1 == 'b0) begin
            rdata2 <= 0;
        end else begin
            if(re2 && we && raddr2 == waddr) begin 
                rdata2 <= wdata;
            end else if(re2)begin
                rdata2 <= regs[raddr1];
            end else begin
                rdata2 <= 0;
            end
        end
    end
    
endmodule