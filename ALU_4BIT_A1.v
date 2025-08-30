`timescale 1ns / 1ps

module ALU_4BIT (
    input [3:0] a,
    input [3:0] b,
    input [2:0] opcode,
    
    // Memory control inputs
    input write_en,
    input [3:0] addr,
    input clk,
    input rst,
    
    // Outputs
    output reg [3:0] result,
    output reg [3:0] mem_out,
    output neg_flag,
    output zero_flag,
    output carry
);

    // Memory: 16 locations of 4 bits each
    reg [3:0] memory [0:15];
    reg [4:0] extended_result;
    integer i;
    // Combinational ALU logic
    always @(*) begin
        case (opcode)
            3'b000: extended_result = a + b;      // ADD
            3'b001: extended_result = a - b;      // SUB
            3'b010: extended_result = a << b;     // LEFT SHIFT
            default: extended_result = 5'b00000;
        endcase

        result = extended_result[3:0];
    end

    // Flags
    assign carry      = (opcode == 3'b000) ? extended_result[4] : 1'b0;
    assign zero_flag  = (result == 4'b0000);
    assign neg_flag   = (opcode == 3'b001 && b > a) ? result[3] : 1'b0;

    // Memory write/reset logic
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                memory[i] <= 4'b0000;

            result   <= 4'b0000;
            mem_out  <= 4'b0000;
        end
        else begin
            if (write_en) begin
                memory[addr] <= result;
            end
        end
    end

    // Memory read (combinational)
    always @(*) begin
        mem_out = memory[addr];
    end

endmodule
