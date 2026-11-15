// IEEE 1800-2023 §6.6.7, §23.7.1, §26.3: resolve C where N is declared.
// §4.7 / §10.3: stimulus at 1,3; settled observations at 2,4.
`timescale 1ns/1ps
package p;
  class C;
    static function real res(input real d[]); res = 0.0; foreach (d[i]) res += d[i]; endfunction
  endclass
  nettype real N with C::res;
endpackage
module top;
  import p::N;
  class C;
    static function real res(input real d[]); return 99.0; endfunction
  endclass
  real a, b;
  N n;
  assign n = a;
  assign n = b;
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f", n);
    if (n != 3.75) $fatal(1, "declaring scope");
    #1 a = 3.5;
    #1 $display("NET %.2f", n);
    if (n != 5.75) $fatal(1, "updated resolution");
    $display("PASS");
    $finish;
  end
endmodule
