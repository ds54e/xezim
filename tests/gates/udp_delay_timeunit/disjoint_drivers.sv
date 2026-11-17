// IEEE 1800-2023 §29.8 / §28.16 / §10.3.3: disjoint drivers retain their bits.
// Sample after the gate's 4ns and the UDP's 5ns propagation times (§4.7).
`timescale 1ns/1ps
primitive copy_udp(q,a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module top;
  reg a;
  wire [1:0] q;
  wire g;
  copy_udp #5 u(q[0],a);
  buf #4 b(g,a);
  assign q[1] = g;
  initial begin
    a=0;
    #6 $display("U|disjoint q=%b g=%b",q,g);
    $finish;
  end
endmodule
