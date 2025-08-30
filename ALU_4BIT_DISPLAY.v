`timescale 1ns / 1ps

module ALU_4BIT (
    input [3:0] a,
    input [3:0] b,
    input [2:0] opcode,
    input rst,clk, eval,

    output reg [3:0] DIGIT_SELECTOR,

    output reg [6:0] LED_out,  // a-g outputs for 7-segment
    output reg neg_flag, zero_flag, carry_flag
);

    reg [3:0] result;
    reg [4:0] extended_result;
    reg [19:0] refresh_counter;
    reg [1:0] led_activating_counter;

    // Arithmetic Logic
    always @(*) 
        begin
            case (opcode)
                3'b000: extended_result = a + b;     // ADD
                3'b001: extended_result = a - b;     // SUB
                3'b010: extended_result = a >> b;       //RIGHT SHIFT
                3'b011: extended_result = a << b;       //LEFT SHIFT
                default: extended_result = 5'b00000; // Default
            endcase
        end

    // Sequential logic to latch result
    always @(posedge clk or posedge rst) 
        begin
            if (rst)
            begin
                result <= 4'b0000;  // Reset the result to zero
                carry_flag <= 1'b0;
                neg_flag <= 1'b0;
                zero_flag <= 1'b0;
            end
            else if (eval)
            begin
                if(opcode == 3'b001 && extended_result[4]) result <= (~extended_result[3:0] + 1);     //EXTRACT MAGNITUDE FROM 2's COMPLEMENT PATTERN
                else result <= extended_result[3:0];  // Update result only on eval
                carry_flag <= (opcode == 3'b000) ? extended_result[4] : 1'b0;
                zero_flag <= (result == 4'b0000);
                neg_flag <= (opcode == 3'b001) ? extended_result[4] : 1'b0;
            end
            else
            begin
                result <= result;  // Hold previous value
            end
        end


    // Clock divider for digit refresh
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            led_activating_counter <= 1'b0;
        end else begin
            if (refresh_counter == 20'd100000) begin  // 1,00,000 - REFRESH PERIOD
                refresh_counter <= 0;
                led_activating_counter <= led_activating_counter + 1;
            end else begin
                refresh_counter <= refresh_counter + 1;
            end
        end
    end

/*OUT OF 4 DISPLAYS; ON PRESSING RESET ONLY RESULT IS DISPLAYED, BECAUSE led_activating_counter = 0.*/

    // HEX to 7-Segment Decoder (active-low for common anode)
    always @(*) begin
    case (led_activating_counter) // Select digit (active low logic)
        2'b00: begin // Display result (magnitude only)
            if(rst)
                DIGIT_SELECTOR = 4'b0110;
            else 
                DIGIT_SELECTOR = 4'b1110;

                case (result)
                    4'h0: LED_out = 7'b0000001;
                    4'h1: LED_out = 7'b1001111;
                    4'h2: LED_out = 7'b0010010;
                    4'h3: LED_out = 7'b0000110;
                    4'h4: LED_out = 7'b1001100;
                    4'h5: LED_out = 7'b0100100;
                    4'h6: LED_out = 7'b0100000;
                    4'h7: LED_out = 7'b0001111;
                    4'h8: LED_out = 7'b0000000;
                    4'h9: LED_out = 7'b0000100;
                    4'hA: LED_out = 7'b0001000;
                    4'hB: LED_out = 7'b1100000;
                    4'hC: LED_out = 7'b0110001;
                    4'hD: LED_out = 7'b1000010;
                    4'hE: LED_out = 7'b0110000;
                    4'hF: LED_out = 7'b0111000;
                    default: LED_out = 7'b1111111;
                endcase
            end

        2'b01: begin // Display minus sign if negative subtraction
            if (opcode == 3'b001 && neg_flag) begin
                DIGIT_SELECTOR = 4'b1101;  // Second digit from right
                LED_out = 7'b1111110;      // Minus sign
            end else begin
                DIGIT_SELECTOR = 4'b1101;
                LED_out = 7'b1111111;      // Blank
            end
        end
        
        2'b10: begin
            DIGIT_SELECTOR = 4'b0111; // Third digit from right
            case (opcode)
                3'b000: LED_out = 7'b0000001; // 0
                3'b001: LED_out = 7'b1001111; // 1
                3'b010: LED_out = 7'b0010010; // 2
                3'b011: LED_out = 7'b0000110; // 3
                default: LED_out = 7'b1111111;
            endcase
        end

        default: begin
            DIGIT_SELECTOR = 4'b1111;
            LED_out = 7'b1111111;
        end
    endcase
end

endmodule
