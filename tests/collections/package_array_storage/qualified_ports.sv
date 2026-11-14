// IEEE 1800-2023 §26.3, §7.4, §7.12: references retain their package owner.
package other;
  typedef struct { int x; int y; } st_t;
  int a[0:1] = '{5, 6}; int m[0:1][0:1] = '{'{1,2},'{3,4}}; st_t st[0:1]; logic [7:0] b[0:1];
endpackage
module sub(input int i0, input int arr[0:1], output int o); assign o = i0 + arr[1]; endmodule
module top;
  int a[0:1]; int m[0:1][0:1]; other::st_t st[0:1]; logic [7:0] b[0:1];
  int o, cnt = 0, x1, x2; logic x3;
  sub u(.i0(other::m[1][1]), .arr(other::a), .o(o));
  always @(other::m[1][1]) cnt++;
  always @(other::st[1].x) cnt += 10;
  always_comb x1 = other::m[0][1] + other::st[0].y;
  assign x2 = other::a[1] + other::a[0];
  assign x3 = other::b[1][3];
  initial begin
    #1 other::m[1][1] = 40; other::st[1].x = 9; other::st[0].y = 7; other::b[1] = 8'h08;
    #1 $display("port=%0d cnt=%0d comb=%0d sum=%0d bit=%b (exp 46 11 9 11 1)", o, cnt, x1, x2, x3);
    $display("proc %0d %0d %0d %p %p", other::m[1][1], other::st[1].x, other::st[0].y, other::a, other::m);
    if (cnt === 11 && o === 46 && x1 === 9 && x2 === 11 && x3 === 1) $display("PASS port and comb"); else $display("FAIL port and comb");
    $finish;
  end
endmodule
