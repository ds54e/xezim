// §29.8 / §3.14.1–§3.14.2: round in the enclosing definition's precision.
`timescale 1ns/1ps
primitive copy_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module child #(parameter real P = 0.26)(input a, output q, literal_q, expr_q);
  timeunit 10ns; timeprecision 1ns;
  copy_udp #(P) u(q, a);
  copy_udp #0.26 v(literal_q, a);
  copy_udp #(P + 0.0) w(expr_q, a);
endmodule
module top;
  reg a;
  wire q1, l1, e1, q2, l2, e2;
  child c1(a, q1, l1, e1);
  child #(.P(0.46)) c2(a, q2, l2, e2);
  initial begin
    a = 0; #10 a = 1;
    #2.5 $display("U|round-before %b%b%b %b%b%b", q1,l1,e1,q2,l2,e2);
    #1 $display("U|round-first %b%b%b %b%b%b", q1,l1,e1,q2,l2,e2);
    #1 $display("U|round-second-before %b%b%b",q2,l2,e2);
    #1 $display("U|round-second-after %b%b%b",q2,l2,e2);
    $finish;
  end
endmodule
