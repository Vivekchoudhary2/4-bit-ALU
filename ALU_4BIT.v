`timescale 1ns / 1ps

module ALU_4BIT (
    input [3:0] a,
    input [3:0] b,
    input [2:0] opcode,

    output reg [3:0] result,
    output neg_flag,
    output zero_flag,
    output carry
);

    reg [4:0] extended_result;

    always @(*) begin
        case (opcode)
            3'b000: extended_result = a + b;    // ADD
            3'b001: extended_result = a - b;    // SUB
            default: extended_result = 5'b00000;
        endcase

        result = extended_result[3:0];          // Assign the lower 4 bits to result
    end

    assign carry = (opcode == 3'b000) ? extended_result[4] : 1'b0;          // Carry flag from the 5th bit
    assign zero_flag = (result == 4'b0000);                                 // Zero flag set if result is 0
    assign neg_flag = (b > a) ? extended_result[3] : 1'b0;

endmodule
