// IEEE 1800-2023 §26.3, §7.4, §7.12: references retain their package owner.
package other;
  typedef struct { int x; int y; } st_t;
  int a[0:2] = '{3, 1, 2}; int m[0:1][0:1] = '{'{1,2},'{3,4}}; st_t st[0:1]; logic [1:0][7:0] pk[0:1]; int c[-2:1];
  function automatic int total(); return a.sum(); endfunction
  function automatic int elem(int i, int j); return m[i][j]; endfunction
  function automatic int diag(); int t = 0; foreach (m[i, j]) if (i == j) t += m[i][j]; return t; endfunction
  function automatic int member(int i); return st[i].x + st[i].y; endfunction
  function automatic void setm(int i, int v); st[i].x = v; st[i].y = v + 1; m[i][i] = v; pk[i][1] = v; c[i - 2] = v; endfunction
  function automatic int neg(int i); return c[i]; endfunction
  function automatic logic [7:0] sub(int i); return pk[i][1]; endfunction
  function automatic void sorta(); a.sort(); endfunction
  function automatic int whole(); int t[0:2]; t = a; return t[0] * 100 + t[1] * 10 + t[2]; endfunction
  function automatic int sz(); return $size(a) * 10 + $size(m, 2); endfunction
  class K;
    function int total(); return a.sum() + m[1][1] + st[1].x; endfunction
    function void put(int v); m[1][0] = v; st[0].y = v; endfunction
  endclass
  int loops;
endpackage
module top;
  int a[0:2]; int m[0:1][0:1]; other::st_t st[0:1]; logic [1:0][7:0] pk[0:1]; int c[-2:1];
  other::K k;
  initial begin
    k = new;
    #1 $display("total=%0d el=%0d diag=%0d whole=%0d sz=%0d (exp 6 4 5 312 32)", other::total(), other::elem(1,1), other::diag(), other::whole(), other::sz());
    if (other::total() === 6 && other::elem(1,1) === 4 && other::diag() === 5 && other::whole() === 312 && other::sz() === 32) $display("PASS package functions"); else $display("FAIL package functions");
    other::setm(1, 9); other::sorta();
    #1 $display("member=%0d el=%0d neg=%0d sub=%h a=%p K=%0d (exp 19 9 9 09 '{1, 2, 3} 24)", other::member(1), other::elem(1,1), other::neg(-1), other::sub(1), other::a, k.total());
    if (other::member(1) === 19 && other::neg(-1) === 9 && other::sub(1) === 8'h09 && other::a[0] === 1 && k.total() === 24) $display("PASS package mutations"); else $display("FAIL package mutations");
    k.put(5);
    #1 $display("put %0d %0d  module arrays still default: %p %p %0d (exp 5 5 '{0, 0, 0} '{'{0, 0}, '{0, 0}} 0)", other::m[1][0], other::st[0].y, a, m, st[1].x);
    if (other::m[1][0] === 5 && other::st[0].y === 5 && a[0] === 0 && m[1][1] === 0 && st[1].x === 0) $display("PASS package class writes"); else $display("FAIL package class writes");
    $finish;
  end
endmodule
