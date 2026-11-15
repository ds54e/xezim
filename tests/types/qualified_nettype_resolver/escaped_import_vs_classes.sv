// IEEE 1800-2023 §5.6.1, §6.6.7, §26.3: imported escaped function name.
`timescale 1ns/1ps
package p;
  function automatic real \C::res (input real d[]); \C::res = 0.0; foreach (d[i]) \C::res += d[i]; endfunction
endpackage
class C;
  static function real res(input real d[]); return 77.0; endfunction
endclass
module top;
  import p::*;
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
    if (n != 3.75) $fatal(1, "escaped resolver binding");
    #1 a = 3.5;
    #1 $display("NET %.2f", n);
    if (n != 5.75) $fatal(1, "escaped resolver update");
    $display("PASS");
    $finish;
  end
  initial #100 $finish;
endmodule
