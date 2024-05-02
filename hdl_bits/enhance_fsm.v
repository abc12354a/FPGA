module enhance_fsm(
    input  wire clk,
    input  wire rst_n,
    input  wire pay,
    input  wire pay_half,
    output reg  ret,
    output reg  coke_out
);
    parameter S_1 = 0;
    parameter S_2 = 1;
    parameter S_3 = 2;
    parameter S_4 = 3;
    parameter S_5 = 4;
    parameter S_6 = 5;
    parameter S_7 = 6;
    // parameter S_8 = 7;

    reg[2:0] state = S_1;
    reg[2:0] n_state = S_1;

    always @(*) begin
        if (!rst_n) begin
            n_state = S_1;
        end else begin
            case (state)
                S_1: n_state = pay?S_3:pay_half?S_2:S_1;
                S_2: n_state = pay?S_4:pay_half?S_3:S_2;
                S_3: n_state = pay?S_5:pay_half?S_4:S_3;
                S_4: n_state = pay?S_6:pay_half?S_5:S_4;
                S_5: n_state = pay?S_7:pay_half?S_6:S_5;
                S_6: n_state = pay?S_3:pay_half?S_2:S_1;
                default: n_state = S_1;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_1;
        end else begin
            state <= n_state;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            coke_out <= 0;
            ret <= 0;
        end else begin
            if(state == S_5 && pay) begin
                coke_out <= 1;
                ret <= 1;
            end else if(state == S_5 && pay_half) begin
                coke_out <= 1;
                ret <= 0;
            end else if(state == S_4 && pay) begin
                coke_out <= 1;
                ret <= 0;
            end else begin
                coke_out <= 0;
                ret <= 0;
            end
        end
    end
endmodule