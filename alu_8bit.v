`timescale 1ns / 1ps

module alu_8bit (
    input  wire [7:0]  InputA,
    input  wire [7:0]  InputB,
    input  wire [2:0]  OpCode,
    output reg  [15:0] OutALU,
    output reg         COut
);

    // Operation Codes
    localparam [2:0] OP_ADD = 3'b000,
                     OP_SUB = 3'b001,
                     OP_MUL = 3'b010,
                     OP_LSL = 3'b011,
                     OP_LSR = 3'b100,
                     OP_AND = 3'b101,
                     OP_OR  = 3'b110,
                     OP_XOR = 3'b111;

    // Intermediate datapath signals
    wire [8:0]  add_result;
    wire [15:0] mult_result;
    wire [3:0]  shift_amt;
    reg  [7:0]  shift_result;

    // 9-bit addition to capture carry-out
    assign add_result  = {1'b0, InputA} + {1'b0, InputB};

    // 16-bit full-precision multiplication
    assign mult_result = InputA * InputB;

    // Lower 4 bits define shift amount (0 to 15)
    assign shift_amt   = InputB[3:0];

    // Combinational ALU logic
    always @(*) begin
        // Default assignments to prevent latch inference
        OutALU       = 16'b0;
        COut         = 1'b0;
        shift_result = 8'b0;

        case (OpCode)
            OP_ADD: begin
                OutALU = {7'b0, add_result};
                COut   = add_result[8];
            end

            OP_SUB: begin
                OutALU = {8'b0, (InputA - InputB)};
                COut   = (InputA < InputB); // Borrow flag
            end

            OP_MUL: begin
                OutALU = mult_result;
                COut   = |mult_result[15:8]; // 8-bit overflow indicator
            end

            OP_LSL: begin
                if (shift_amt == 4'd0) begin
                    OutALU = {8'b0, InputA};
                end else if (shift_amt < 4'd8) begin
                    shift_result = InputA << shift_amt;
                    OutALU       = {8'b0, shift_result};
                    COut         = (InputA >> (4'd8 - shift_amt)) & 1'b1;
                end
            end

            OP_LSR: begin
                if (shift_amt == 4'd0) begin
                    OutALU = {8'b0, InputA};
                end else if (shift_amt < 4'd8) begin
                    shift_result = InputA >> shift_amt;
                    OutALU       = {8'b0, shift_result};
                    COut         = (InputA >> (shift_amt - 4'd1)) & 1'b1;
                end
            end

            OP_AND: begin
                OutALU = {8'b0, (InputA & InputB)};
            end

            OP_OR: begin
                OutALU = {8'b0, (InputA | InputB)};
            end

            OP_XOR: begin
                OutALU = {8'b0, (InputA ^ InputB)};
            end

            default: begin
                OutALU       = 16'b0;
                COut         = 1'b0;
                shift_result = 8'b0;
            end
        endcase
    end

endmodule


