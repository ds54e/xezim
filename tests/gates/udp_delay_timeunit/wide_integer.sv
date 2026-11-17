// §5.7.1 / §3.14.1–§3.14.2 / §29.8: integral delays stay exact when
// module units scale to ticks; conversion through real must be avoided.
`timescale 1ns/1ns
primitive copy_udp(q,a); output q; input a; table 0:0; 1:1; endtable endprimitive
module top;
  localparam [63:0] D = 64'd9007199254740993;
  reg a; wire [1:0] q;
  copy_udp #(64'd9007199254740993) ul(q[0],a);
  copy_udp #(D) up(q[1],a);
  initial begin a=0; #1 $display("U|wide-pending %b",q); $finish; end
endmodule
