// IEEE 1800-2023 §6.6.7 / §8.6: unused static class resolvers are legal.
// No nets use these declarations; there are no driver or sampling races.
`timescale 1ns/1ps
class C;
  static function real res(input real d[]);
    res = 0.0; foreach (d[i]) res += d[i];
  endfunction
endclass
package p;
  class D;
    static function real res(input real d[]);
      res = 0.0; foreach (d[i]) res += d[i];
    endfunction
  endclass
endpackage
nettype real UnitN with C::res;
nettype real PackageN with p::D::res;
module top;
  nettype real LocalN with C::res;
  initial begin #1; $display("PASS"); $finish; end
endmodule
