// Compatibility regression for unsized_decimal_wrap_warning.rs and the
// comment above core's warn_unsized_decimal_wrap: "That wrap is deliberate
// and stays." These are upstream-policy expectations, not IEEE 1800-2023
// §5.7.1 minimum widths for wide signed decimals. Unsigned 'd keeps its digits
// per unsized_literal_keeps_its_digits.rs and §5.7.1. Assignments: §10.3/§10.4;
// expressions: §11.4; $bits: §20.6.2; decimal display: §21.2.1.
module top;
  localparam P = 2000000000000;
  localparam Q = 4294967297;
  longint x, y;
  wire signed [63:0] a, b;
  assign a = 2000000000000;
  assign b = 4294967297;
  initial begin
    x = 2000000000000;
    y = 4294967297;
    #1; // §4.7: sample after the continuous assignments settle.
    $display("policy %0d %0d %0d %0d %0d %0d", P, x, a, Q, y, b);
    $display("widths %0d %0d %0d %0d", $bits(P), $bits(2000000000000), $bits(Q), $bits(4294967297));
    $display("direct %0d %0d", 2000000000000, 4294967297);
    $display("expressions %0d %0d", 4294967297 + 1, -2000000000000);
    $display("real %.0f", 2.0 * 2000000000000);
    $display("decimal_base %0d %0d", 'd2000000000000, $bits('d2000000000000));
    $display("guards %0d %0d %0d %0d %0d %0d", 2147483647, 64'd2000000000000, 'h1_0000_0001, -2147483648, $bits(64'd2000000000000), $bits('h1_0000_0001));
  end
endmodule
