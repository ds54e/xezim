// IEEE 1800-2023 §6.6.7: scoped resolution functions and nettype aliases.
// §8.6: class methods have automatic lifetime; §26.3: package imports.
// §4.7 / §10.3: drive at 1,3 and sample settled nets at 2,4.
`timescale 1ns/1ps
package p;
  typedef struct { real x; real y; } T;
  function automatic T res(input T d[]);
    res = '{0.0, 0.0};
    foreach (d[i]) begin res.x += d[i].x; res.y += d[i].y; end
  endfunction
endpackage
module top;
  nettype p::T N with p::res;
  N n;
  real a, b;
  assign n = '{a, 10.0};
  assign n = '{b, 20.0};
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f %.2f", n.x, n.y);
    if (n.x != 3.75 || n.y != 30.0) $fatal(1, "initial struct resolution");
    #1 a = 3.5;
    #1 $display("NET %.2f %.2f", n.x, n.y);
    if (n.x != 5.75 || n.y != 30.0) $fatal(1, "changed struct resolution");
    $display("PASS"); $finish;
  end
endmodule
