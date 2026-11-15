// IEEE 1800-2023 §6.12 / footnote 19, §11.4.3, §20.5:
// unary minus reverses the IEEE 754 sign, including zero; subtraction differs.
`timescale 1ns/1ps
// §8.6: cover real-returning fallback and compiled methods with real locals.
class RealNegator;
  function real neg(input real a); return -a; endfunction
  function void local_negation(input bit show_result);
    real z;
    z = 0.0;
    z = -z;
    if (show_result) $display("T|compiled_local|%h", $realtobits(z));
  endfunction
endclass
module real_negation;
  parameter real P = -0.0;
  localparam real L = -0.0;
  real x, y, comb, called;
  shortreal s;
  int i;
  RealNegator c;
  real method_result;
  logic [63:0] nan_bits;
  logic [7:0] u;
  logic signed [7:0] v;
  logic [95:0] wide;
  // §13.4: the function has no timing controls or side effects.
  function automatic real neg(input real a);
    return -a;
  endfunction
  // §10.3 and §9.2.2.2: sample after the combinational update has settled.
  assign comb = -x;
  always_comb called = neg(x);
  initial begin
    c = new;
    x = 0.0;
    #1;
    y = -x;
    $display("T|zero|%h %h %h %h", $realtobits(-0.0), $realtobits(y),
             $realtobits(comb), $realtobits(called));
    $display("T|const|%h %h", $realtobits(P), $realtobits(L));
    $display("T|subtract|%h %h", $realtobits(0.0 - x), $realtobits(-(-0.0)));
    // §21.2.1.1: check exponential output; probe the separate %g zero gap.
    $display("T|format|%e", y);
    $display("F|format_g|%g", y);
    x = $bitstoreal(64'h8000000000000000);
    #1;
    $display("T|negative_zero|%h %h %h", $realtobits(-x), $realtobits(comb), $realtobits(called));
    x = 1.5;
    #1;
    $display("T|positive|%h %h %h", $realtobits(-x), $realtobits(comb), $realtobits(called));
    x = -1.5;
    #1;
    $display("T|negative|%h %h %h", $realtobits(-x), $realtobits(comb), $realtobits(called));
    // Cross the default tier; real-returning methods retain AST fallback.
    repeat (1002) method_result = c.neg(0.0);
    $display("T|method|%h", $realtobits(method_result));
    // A void method with a real local is admitted to compiled execution.
    repeat (1002) c.local_negation(0);
    c.local_negation(1);
    x = $bitstoreal(64'h7ff0000000000000);
    $display("T|infinity|%h", $realtobits(-x));
    x = $bitstoreal(64'hfff0000000000000);
    $display("T|negative_infinity|%h", $realtobits(-x));
    x = $bitstoreal(64'h7ff8000000000001);
    nan_bits = $realtobits(-x);
    $display("T|nan|%b %b %b", nan_bits[63], nan_bits[62:52] == 11'h7ff,
             nan_bits[51:0] != 0);
    s = 0.0;
    $display("T|shortreal|%h", $shortrealtobits(-s));
    s = $bitstoshortreal(32'h80000000);
    $display("T|shortreal_negative|%h", $shortrealtobits(-s));
    i = 7; u = 8'd3; v = -8'sd3; wide = 96'd1;
    $display("T|integer|%0d %h %0d %h %h", -i, -u, -v, -wide, -8'bx);
    $finish;
  end
endmodule
