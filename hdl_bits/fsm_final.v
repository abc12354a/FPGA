module top_module (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output shift_ena,
    output counting,
    input done_counting,
    output done,
    input ack );
    
    parameter Wait  = 0;
    parameter Shift = 1;
    parameter Count = 2;
    parameter Done  = 3;
    
    reg shift_ena_r;
    reg counting_r;
    reg done_r;
    assign shift_ena = shift_ena_r;
    assign counting  = counting_r;
    assign done      = done_r;
    
    reg [3:0] state;
    reg [3:0] nxt_state;
    reg [2:0] shif_count;
    reg [3:0] data_detect;
    reg event_done;
    always @(posedge clk) begin
        if(reset) begin
            state <= Wait;
        end else begin
            state <= nxt_state;
        end
    end

    always @(*) begin
        case (state)
            Wait: begin
                if((data_detect == 4'b0110 || data_detect == 4'b1110)&&data == 1) begin
                    nxt_state = Shift;
                end else begin
                    nxt_state = Wait;
                end
            end
            Shift: begin
                if(shif_count == 4) begin
                    nxt_state = Count;
                end else begin
                    nxt_state = Shift;
                end
            end
            Count: begin
                if(done_counting == 1) begin
                    nxt_state = Done;
                end else begin
                    nxt_state = Count;
                end
            end

            Done: begin
                if(ack == 1) begin
                    nxt_state = Wait;
                end else begin
                    nxt_state = Done;
                end
            end
            
            default: nxt_state = Wait;
        endcase
    end

    always @(posedge clk) begin
        if(reset || state!= Wait) begin
            data_detect <= 4'b0;
        end else begin
            data_detect <= {data_detect[2:0],data};
        end
    end

    always @(posedge clk) begin
        if(reset || nxt_state != Shift) begin
            shif_count <= 0;
            shift_ena_r <= 0;
        end else begin
            shift_ena_r <= 1;
            shif_count <= shif_count +1;
        end
    end

    always @(posedge clk) begin
        if(reset || nxt_state != Count) begin
            counting_r <= 0;
        end else begin
            counting_r <= 1;
        end
    end

    always @(posedge clk) begin
        if(reset || nxt_state != Done) begin
            done_r <= 0;
        end else begin
            done_r <= 1;
        end
    end
    
endmodule
