
`timescale 1ns / 1ps

module alu_8bit_tb_final;

    // Testbench signals
    reg  [7:0]  InputA;
    reg  [7:0]  InputB;
    reg  [2:0]  OpCode;

    wire [15:0] OutALU;
    wire        COut;

    // Scoreboard counters
    integer total_tests;
    integer error_count;

    // Instantiate Device Under Test (DUT)
    alu_8bit uut (
        .InputA (InputA),
        .InputB (InputB),
        .OpCode (OpCode),
        .OutALU (OutALU),
        .COut   (COut)
    );

    // Reusable self-checking verification task
    task check_alu;
        input [7:0]  a_in;
        input [7:0]  b_in;
        input [2:0]  op_in;
        input [15:0] exp_out;
        input        exp_cout;
        begin
            InputA = a_in;
            InputB = b_in;
            OpCode = op_in;
            #10;

            total_tests = total_tests + 1;

            if ((OutALU !== exp_out) || (COut !== exp_cout)) begin
                $display("FAIL [Test %0d] @ %0t ns | Op=%b A=%0d B=%0d | Expected: Out=%0d COut=%b | Got: Out=%0d COut=%b",
                         total_tests, $time, op_in, a_in, b_in, exp_out, exp_cout, OutALU, COut);
                error_count = error_count + 1;
            end else begin
                $display("PASS [Test %0d] @ %0t ns | Op=%b A=%0d B=%0d | Out=%0d COut=%b",
                         total_tests, $time, op_in, a_in, b_in, OutALU, COut);
            end
        end
    endtask

    initial begin
        total_tests = 0;
        error_count = 0;
        InputA      = 8'd0;
        InputB      = 8'd0;
        OpCode      = 3'b000;

        $display("=========================================================");
        $display("   8-BIT ALU SELF-CHECKING VERIFICATION START");
        $display("=========================================================");

        // --- Nominal Test Vectors (Case 1: A=45, B=38) ---
        check_alu(8'd45, 8'd38, 3'b000, 16'd83,  1'b0); // Test 1: ADD
        check_alu(8'd45, 8'd38, 3'b001, 16'd7,   1'b0); // Test 2: SUB
        check_alu(8'd45, 8'd38, 3'b110, 16'd47,  1'b0); // Test 3: OR
        check_alu(8'd45, 8'd38, 3'b111, 16'd11,  1'b0); // Test 4: XOR

        // --- Nominal Test Vectors (Case 2: A=49, B=10) ---
        check_alu(8'd49, 8'd10, 3'b010, 16'd490, 1'b1); // Test 5: MUL (overflow flag)
        check_alu(8'd49, 8'd10, 3'b011, 16'd0,   1'b0); // Test 6: LSL (shift >= 8 saturation)
        check_alu(8'd49, 8'd10, 3'b100, 16'd0,   1'b0); // Test 7: LSR (shift >= 8 saturation)
        check_alu(8'd49, 8'd10, 3'b101, 16'd0,   1'b0); // Test 8: AND

        // --- Boundary & Corner-Case Vectors ---
        check_alu(8'd200, 8'd100, 3'b000, 16'd300, 1'b1); // Test 9:  8-bit Addition Carry-Out
        check_alu(8'd20,  8'd50,  3'b001, 16'd226, 1'b1); // Test 10: Subtraction Underflow/Borrow
        check_alu(8'd129, 8'd1,   3'b011, 16'd2,   1'b1); // Test 11: LSL MSB Shift-Out
        check_alu(8'd129, 8'd1,   3'b100, 16'd64,  1'b1); // Test 12: LSR LSB Shift-Out
        check_alu(8'd85,  8'd0,   3'b011, 16'd85,  1'b0); // Test 13: Zero-Shift Pass-Through

        // --- Final Verification Summary ---
        $display("=========================================================");
        $display("   VERIFICATION COMPLETE");
        $display("   TOTAL TESTS = %0d", total_tests);
        $display("   ERROR COUNT = %0d", error_count);
        if (error_count == 0)
            $display("   STATUS      = ALL TESTS PASSED");
        else
            $display("   STATUS      = VERIFICATION FAILED");
        $display("=========================================================");

        #10;
        $finish;
    end

endmodule

