// §3.14.2.3: unspecified time unit/precision use tool defaults.
primitive copy_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module top;
  reg a; wire q;
  copy_udp #4 u(q,a);
  initial begin
    a=0; #10 a=1;
    #1 $display("U|default-before %b",q);
    #4 $display("U|default-after %b",q);
    $finish;
  end
endmodule
