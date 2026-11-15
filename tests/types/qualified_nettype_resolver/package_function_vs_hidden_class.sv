// IEEE 1800-2023 §23.7.1 / §26.3: a foreign unimported class cannot
// capture a package-function prefix in the nettype declaration scope.
`timescale 1ns/1ps
package C;
  function automatic real res(input real d[]); res = 0.0; foreach (d[i]) res += d[i]; endfunction
endpackage
package q;
  nettype real N with C::res;
endpackage
package r;
  class C;
    static function real res(input real d[]); return 99.0; endfunction
  endclass
endpackage
module top;
  import q::N;
  import r::*;
  real a, b;
  N n;
  assign n = a;
  assign n = b;
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f", n);
    if (n != 3.75) $fatal(1, "package prefix binding");
    #1 a = 3.5;
    #1 $display("NET %.2f", n);
    if (n != 5.75) $fatal(1, "package prefix update");
    $display("PASS");
    $finish;
  end
  initial #100 $finish;
endmodule
