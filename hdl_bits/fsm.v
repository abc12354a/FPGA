module fsm(
    input  wire clk,
    input  wire rst_n,
    input  wire pay,
    output reg  coke_out
);
    parameter S_1 = 0;
    parameter S_2 = 1;
    parameter S_3 = 2;
    parameter S_4 = 3;

    reg[1:0] state = S_1;
    reg[1:0] n_state = S_1;

    always @(*) begin
        if (!rst_n) begin
            n_state = S_1;
        end else begin
            case (state)
                S_1: n_state = pay?S_2:S_1;
                S_2: n_state = pay?S_3:S_2;
                S_3: n_state = pay?S_4:S_3;
                S_4: n_state = pay?S_2:S_1;
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
        end else begin
            if(state == S_3 && pay == 1) begin
                coke_out <= 1;
            end else begin
                coke_out <= 0;
            end
        end
    end
endmodule