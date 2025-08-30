`timescale 1ns / 1ps

module ALU_4BIT_tb;
wire [3:0] result, mem_out;
wire zero_flag, carry, neg_flag;
reg [3:0] a, b;
reg [3:0] addr;
reg [2:0] opcode;
reg clk, rst, write_en;

ALU_4BIT alu1 (
        .a(a), .b(b), .opcode(opcode),
        .clk(clk), .rst(rst),
        .write_en(write_en), .addr(addr),
        .result(result),
        .mem_out(mem_out),
        .zero_flag(zero_flag), .carry(carry), .neg_flag(neg_flag)
    );
    
    always #5 clk = ~clk;

    initial
        $monitor("Time: %0t | a=%d, b=%d, opcode=%b | result=%d | mem_out=%d | carry=%b | zero=%b | neg=%b | addr=%d | write_en=%b",
                  $time, a, b, opcode, result, mem_out, carry, zero_flag, neg_flag, addr, write_en);
        
        
    initial begin
    
        clk = 0;
        rst = 1;
        write_en = 0;
        a = 0; b = 0; opcode = 0; addr = 0;
        #12
        
        rst = 0;
        
        
        // ADD WITH CARRY (0)   15 + 5
        a = 4'b1111; b = 4'b0001; opcode = 3'b000; 
        addr = 4'd3;
        write_en = 1;
        #10;
        
        // ADD WITH NO CARRY (0)    10 + 3
        a = 4'b1010; b = 4'b0011; opcode = 3'b000;
        addr = 4'd4;
        #10;

        //SUB WITH NO NEG_FLAG (1)      11 - 7
        a = 4'b1011; b = 4'b0111; opcode = 3'b001;
        addr = 4'd5;
        #10
        
        write_en = 0;
        
        addr = 4'd3;
        #10
        
        addr = 4'd4;
        #10
        
        addr = 4'd5;
        #10

        $finish;
    end
endmodule
