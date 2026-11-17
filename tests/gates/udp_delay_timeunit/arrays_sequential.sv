// §29.8: arrays and sequential UDPs use the same instance delay.
// §29.5: a level-sensitive sequential table stores state when en=0.
`timescale 1ns/1ps
primitive copy_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
primitive latch_udp(q, en, a);
  output q; reg q; input en, a;
  table
    0 ? : ? : -;
    1 0 : ? : 0;
    1 1 : ? : 1;
  endtable
endprimitive
module top;
  reg [1:0] a;
  reg en;
  wire [1:0] q;
  wire s;
  copy_udp #4 u[1:0](q,a);
  latch_udp #(4,6) v(s,en,a[0]);
  initial begin
    a=0; en=1;
    #10 a=3;
    #1 $display("U|array-before %b %b",q,s);
    #4 $display("U|array-after %b %b",q,s);
    #1 en=0;
    #4 a=0;
    #5 $display("U|hold %b %b",q,s);
    #5 en=1;
    #1 $display("U|seq-before %b",s);
    #6 $display("U|seq-after %b",s);
    $finish;
  end
endmodule
