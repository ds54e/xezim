// §3.14.2.1 / §29.8: the cell has its own 1ps unit; gate is the control.
`timescale 1ps/1ps
primitive lib_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module delay_cell(input a, output u, g);
  lib_udp #4 uu(u, a);
  buf #4 gg(g, a);
endmodule
