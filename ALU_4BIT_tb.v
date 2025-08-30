`timescale 1ns / 1ps

module ALU_4BIT_tb;
wire [3:0] result;
wire zero_flag, carry, neg_flag;
reg [3:0] a, b;
reg [2:0] opcode;

ALU_4BIT alu1(.a(a), .b(b), .opcode(opcode), .result(result), .zero_flag(zero_flag), .carry(carry), .neg_flag(neg_flag));

    initial
        $monitor("a = %d | b = %d | result = %d | zero_flag = %b | carry = %b | neg_flag = %b|", a, b, result, zero_flag, carry, neg_flag);
        
    initial begin
        
        // ADD WITH CARRY (0)   15 + 5
        a = 4'b1111; b = 4'b0101; opcode = 3'b000;
        #10;
        
        // ADD WITH NO CARRY (0)    10 + 3
        a = 4'b1010; b = 4'b0011; opcode = 3'b000;
        #10;

        //SUB WITH NO NEG_FLAG (1)      11 - 7
        a = 4'b1011; b = 4'b0111; opcode = 3'b001;
        #10

        // SUB WITH NEG_FLAG (1)        7 - 10
        a = 4'b0111; b = 4'b1010; opcode  = 3'b001;
        #10;
        
        // SUB WITH NO NEG_FLAG (1)        12 - 4 = 8 (1000)
        a = 4'b1100; b = 4'b0100; opcode  = 3'b001;
        #10;

        $finish;
    end
endmodule
