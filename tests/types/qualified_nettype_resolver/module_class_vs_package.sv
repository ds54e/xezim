// IEEE 1800-2023 §23.7.1, §8.23, §6.6.7: the visible class prefix wins.
`timescale 1ns/1ps
package p;
  function automatic real res(input real d[]); return 99.0; endfunction
endpackage
module top;
  class p;
    static function real res(input real d[]);
      res = 0.0;
      foreach (d[i]) res += d[i];
    endfunction
  endclass
  nettype real N with p::res;
  real a, b;
  N n;
  assign n = a;
  assign n = b;
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f", n);
    if (n != 3.75) $fatal(1, "class prefix binding");
    #1 a = 3.5;
    #1 $display("NET %.2f", n);
    if (n != 5.75) $fatal(1, "class prefix update");
    $display("PASS");
    $finish;
  end
  initial #100 $finish;
endmodule
