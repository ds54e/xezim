// §3.14.2.3 a) / §23.4: inner inherits outer's 1ps/1ps scope.
// §29.8 / §28.16: the UDP and gate each delay by 4ps.
`timescale 1ps/1ps
primitive copy_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module outer(input a, output u, g);
  module inner(input a, output u, g);
    copy_udp #4 uu(u, a);
    buf #4 gg(g, a);
  endmodule
  inner i(a, u, g);
endmodule
`timescale 1ns/1ps
module top;
  reg a; wire u, g;
  outer o(a, u, g);
  initial begin
    a = 0; #10 a = 1;
    #0.002 $display("U|nested-before %b%b", u, g);
    #0.004 $display("U|nested-after %b%b", u, g);
    $finish;
  end
endmodule
