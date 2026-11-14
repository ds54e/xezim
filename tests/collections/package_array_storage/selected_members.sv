// IEEE 1800-2023 §26.3, §7.4, §7.12: references retain their package owner.
package other;
  typedef struct { int x; int y; } st_t;
  int m[0:1][0:1];
  st_t st[0:1];
  logic [1:0][7:0] pk[0:1];
endpackage
module top;
  int m[0:1][0:1];            // declared, never written
  other::st_t st[0:1];
  logic [1:0][7:0] pk[0:1];
  int e1, e2; logic [7:0] e3;
  assign e1 = other::m[1][1];
  assign e2 = other::st[1].x;
  assign e3 = other::pk[1][1];
  initial begin
    #1 other::m[1][1] = 20; other::st[1].x = 10; other::pk[1] = 16'h7080;
    #1;
    if (e1 === 20) $display("PASS 2-D element"); else $display("FAIL 2-D element %0d", e1);
    if (e2 === 10) $display("PASS struct member"); else $display("FAIL struct member %0d", e2);
    if (e3 === 8'h70) $display("PASS packed sub-element"); else $display("FAIL packed sub-element %h", e3);
    $finish;
  end
endmodule
