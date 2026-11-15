// IEEE 1800-2023 §6.6.7, §23.7.1, §26.3: resolve C where N is declared.
// §4.7 / §10.3: stimulus at 1,3; settled observations at 2,4.
`timescale 1ns/1ps
package p;
  class C;
    static function real res(input real d[]); res = 0.0; foreach (d[i]) res += d[i]; endfunction
  endclass
  nettype real Np with C::res;
endpackage
package q;
  class C;
    static function real res(input real d[]); res = 1000.0; foreach (d[i]) res += d[i]; endfunction
  endclass
  nettype real Nq with C::res;
endpackage
module top;
  import p::Np;
  import q::Nq;
  real a, b;
  Np n;
  Nq m;
  assign n = a;
  assign n = b;
  assign m = a;
  assign m = b;
  initial begin
    #1 a = 1.5; b = 2.25;
    #1 $display("NET %.2f %.2f", n, m);
    if (n != 3.75 || m != 1003.75) $fatal(1, "declaring package");
    #1 a = 3.5;
    #1 $display("NET %.2f %.2f", n, m);
    if (n != 5.75 || m != 1005.75) $fatal(1, "updated package resolution");
    $display("PASS");
    $finish;
  end
endmodule
