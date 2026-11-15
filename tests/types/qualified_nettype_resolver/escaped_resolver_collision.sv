// IEEE 1800-2023 §5.6.1: an escaped identifier can contain literal `::`.
// §23.7.1: class-prefix qualification must preserve this ordinary function.
// §4.7 / §10.3: sample settled resolution, away from stimulus times.
`timescale 1ns/1ps
function automatic real \C::res (input real d[]);
  \C::res = 0.0;
  foreach (d[i]) \C::res += d[i];
endfunction
class C;
  static function real res(input real d[]); return 77.0; endfunction
endclass
module top;
  class C;
    static function real res(input real d[]); return 99.0; endfunction
  endclass
  nettype real N with \C::res ;
  real a, b;
  N n;
  assign n = a;
  assign n = b;
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f", n);
    if (n != 3.75) $fatal(1, "literal resolver name");
    #1 a = 3.5;
    #1 $display("NET %.2f", n);
    if (n != 5.75) $fatal(1, "updated literal resolver");
    $display("PASS");
    $finish;
  end
endmodule
