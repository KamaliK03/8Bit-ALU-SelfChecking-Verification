
`timescale 1ns / 1ps

module alu_8bit_tb_initial;

    // Testbench inputs
    reg [7:0] InputA;
    reg [7:0] InputB;
    reg [2:0] OpCode;

    // Testbench outputs
    wire [15:0] OutALU;
    wire COut;

    // Instantiate the ALU
    alu_8bit uut (
        .InputA(InputA),
        .InputB(InputB),
        .OpCode(OpCode),
        .OutALU(OutALU),
        .COut(COut)
    );

    initial begin

        $display("==================================");
        $display("       8-BIT ALU TESTBENCH");
        $display("==================================");

        // Test 1: Addition
        InputA = 8'd45;
        InputB = 8'd38;
        OpCode = 3'b000;
        #10;
        $display("ADD: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Test 2: Subtraction
        OpCode = 3'b001;
        #10;
        $display("SUB: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Test 3: OR
        OpCode = 3'b110;
        #10;
        $display("OR : A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Test 4: XOR
        OpCode = 3'b111;
        #10;
        $display("XOR: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Change inputs for second group
        InputA = 8'd49;
        InputB = 8'd10;

        // Test 5: Multiplication
        OpCode = 3'b010;
        #10;
        $display("MUL: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Test 6: Left shift
        OpCode = 3'b011;
        #10;
        $display("LSL: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Test 7: Right shift
        OpCode = 3'b100;
        #10;
        $display("LSR: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        // Test 8: AND
        OpCode = 3'b101;
        #10;
        $display("AND: A=%d B=%d Out=%d COut=%b",
                  InputA, InputB, OutALU, COut);

        $display("==================================");
        $display("       TESTS COMPLETED");
        $display("==================================");

        $finish;
    end

endmodule
