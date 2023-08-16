module div (
    input                                   clk,
    input                                   rst_n,
    input                                   signed_div_in,
    input[`REG_DATA_WIDTH-1:0]              dived_in,
    input[`REG_DATA_WIDTH-1:0]              div_in,
    input                                   div_start_in,
    input                                   div_cancel_in,
    output reg[`DOUBLE_DATA_WIDTH-1:0]      div_res_out,
    output reg                              div_ready_out
);
    wire[`REG_DATA_WIDTH:0]      div_tmp; //33bit
    wire[`REG_DATA_WIDTH-1:0]    div_op1;
    wire[`REG_DATA_WIDTH-1:0]    div_op2;
    reg[5:0]                     div_cnt;
    reg[`DOUBLE_DATA_WIDTH:0]    divend;   //65bit
    reg[`REG_DATA_WIDTH-1:0]     divisor;
    reg[1:0]                     div_state;
    

    assign div_tmp = {1'b0,divend[63:32]} - {1'b0,divisor};
    assign div_op1 = (signed_div_in & dived_in[31])? (~dived_in+1'b1):(dived_in);
    assign div_op2 = (signed_div_in & div_in[31])? (~div_in+1'b1):(div_in);

    always @(posedge clk) begin
        if(!rst_n) begin
            div_state <= `DIV_FREE;
            div_ready_out <= 0;
            div_res_out <= 0;
            div_cnt <= 0;
        end else begin
            case (div_state)
                `DIV_FREE: begin
                    if(div_start_in & !div_cancel_in) begin
                        if(div_in == 'h0) begin
                            div_state <= `DIV_ZERO;
                        end else begin
                            div_state <= `DIV_ON;
                            div_cnt <= 'h0;
                            divend <= {32'h0,div_op1,1'b0};
                            divisor<= div_op2;
                        end
                    end else begin
                        div_ready_out <= 0;
                        div_res_out <= 0;
                    end
                end 
                `DIV_ZERO: begin
                    divend <= 'h0;
                    div_state <= `DIV_END;
                end
                `DIV_ON: begin
                    if(!div_cancel_in) begin
                        if(div_cnt <= 6'b10_0000) begin
                            if(div_tmp[32] == 1'b1) begin//minuend-n < 0
                                divend <= {divend[63:0],1'b0};
                            end else begin
                                divend <= {div_tmp[31:0],divend[31:0],1'b1};
                            end
                            div_cnt <= div_cnt + 1;
                        end else begin // end of div 32bit
                            if(signed_div_in & (dived_in[31] ^ div_in[31])) begin
                                divend[31:0] <= (~divend[31:0]+1'b1);
                            end
                            if(signed_div_in & (dived_in[31] ^ divend[64])) begin
                                divend[64:33] <= (~divend[31:0]+1'b1);
                            end
                            div_state <= `DIV_END;
                            div_cnt <= 'h0;
                        end 
                    end else begin //cancel in div ongoing
                        div_state <= `DIV_FREE;
                    end
                end
                `DIV_END: begin
                    if(!div_start_in) begin
                        div_res_out <= 0;
                        div_ready_out <= 0;
                        div_state <= `DIV_FREE;
                    end else begin
                        div_res_out <= {divend[64:33],divend[31:0]};
                        div_ready_out <= 1;
                    end
                end
                default: begin
                    div_state <= `DIV_FREE;
                    div_ready_out <= 0;
                    div_res_out <= 0;
                end
            endcase
        end
    end
endmodule