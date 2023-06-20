module top_module (
    input clk,
    input reset,      // Synchronous reset
    output shift_ena);

    parameter A = 0, B=1,C=2,D=3,E=4;
    reg shift_ena_r;
    reg[2:0] state;
    reg[2:0] nxt_state;
    assign shift_ena = shift_ena_r;
    assign shift_ena_r = (state != E);
    
    always @(posedge clk) begin
        if(reset) begin
            state <= A;
        end else begin
            state <=  nxt_state;
        end
    end

    always @(*) begin
        case (state)
            A: nxt_state = reset?A:B;
            B: nxt_state = C;
            C: nxt_state = D;
            D: nxt_state = E;
            E: nxt_state = E;
            default: nxt_state = E;
        endcase
    end
endmodule