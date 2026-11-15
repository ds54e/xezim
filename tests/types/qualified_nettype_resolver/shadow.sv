// IEEE 1800-2023 §6.6.7: scoped resolution functions and nettype aliases.
// §8.6: class methods have automatic lifetime; §26.3: package imports.
// §4.7 / §10.3: drive at 1,3 and sample settled nets at 2,4.
`timescale 1ns/1ps
package p;
  function automatic real res(input real d[]);
    res = 0.0;
    foreach (d[i]) res += d[i];
  endfunction
endpackage
module top;
  function automatic real res(input real d[]); return 99.0; endfunction
  nettype real N with p::res;
  real a, b;
  N n;
  assign n = a;
  assign n = b;
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f", n);
    if (n != 3.75) $fatal(1, "initial resolution");
    #1 a = 3.5;
    #1 $display("NET %.2f", n);
    if (n != 5.75) $fatal(1, "changed resolution");
    $display("PASS");
    $finish;
  end
endmodule
