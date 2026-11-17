// §28.16 / §29.8: single and rise/fall delay forms.
// Guards for main's unknown rise (zero) and variable fall (rise fallback).
// Observations are away from stimulus and propagation times (§4.7).
`timescale 1ns/1ns
primitive copy_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module top;
  reg a;
  reg [7:0] dly = 4;
  wire xq, vq;
  copy_udp #(4'b01x0) ux(xq, a);
  copy_udp #(4, dly) uv(vq, a);
  initial begin
    a = 0; #10 a = 1;
    #1 $display("U|fallback-rise %b %b", xq, vq);
    #9 a = 0;
    #1 $display("U|fallback-fall %b %b", xq, vq);
    #4 $display("U|fallback-after %b %b", xq, vq);
    $finish;
  end
endmodule
