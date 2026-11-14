// IEEE 1800-2023 §23.9, §26.3: module declarations own their storage.
// §7.2.1/§7.2.2 and §7.4.1/§7.4.2: packed elements and two unpacked dimensions.
// §4.7: stimulus and observation occupy different time slots.
package other;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } pair_t;
  typedef struct { int x; int y; } plain_t;
  plain_t plain[0:1]; plain_t plain_matrix[0:1][0:1];
  int a[0:1] = '{31, 32};
  int s = 33;
  logic [1:0][7:0] packed_a[0:1];
  int matrix[0:1][0:1];
  pair_t records[0:1];
  wire [7:0] wires[0:1];
endpackage
module child #(parameter int V=10) (output int result);
  int a[0:1];
  assign result = a[1];
  initial #1 a[1] = V;
endmodule
module top;
  int a[0:1];
  int s;
  logic [1:0][7:0] packed_a[0:1];
  int matrix[0:1][0:1];
  other::pair_t records[0:1];
  other::plain_t plain[0:1]; other::plain_t plain_matrix[0:1][0:1];
  wire [7:0] wires[0:1];
  int ca, cs, star, comb, c1, c2;
  assign ca = a[1];
  assign cs = s;
  always @* star = a[1];
  always_comb comb = a[1];
  assign wires[1] = 8'd9;
  assign other::wires[1] = 8'd39;
  child #(11) u1(c1);
  child #(12) u2(c2);
  function int read_local(); return a[1]; endfunction
  function int read_package(); return other::a[1]; endfunction
  task write_local(input int v); a[1] = v; endtask
  task write_package(input int v); other::a[1] = v; endtask
  task check(input string label, input int got, expected);
    if (got === expected) $display("PASS %s", label);
    else $display("FAIL %s got=%0d expected=%0d", label, got, expected);
  endtask
  initial begin
    #1;
    a[1] = 6; s = 3; other::a[1] = 38; other::s = 33;
    packed_a[1] = 16'h1234; other::packed_a[1] = 16'habcd;
    matrix[1][1] = 7; other::matrix[1][1] = 37;
    records[1] = 16'h4567; other::records[1] = 16'h89ab;
    plain[1].x=6; plain[1].y=7; other::plain[1].x=38; other::plain[1].y=39;
    plain_matrix[1][1].x=8; other::plain_matrix[1][1].x=40;
    #1;
    check("continuous local", ca, 6); check("scalar guard", cs, 3);
    check("always star local", star, 6); check("always comb local", comb, 6);
    check("procedural local", a[1], 6); check("procedural package", other::a[1], 38);
    check("function local", read_local(), 6); check("function package", read_package(), 38);
    check("packed element local", packed_a[1], 16'h1234);
    check("packed element package", other::packed_a[1], 16'habcd);
    check("two dimensional local", matrix[1][1], 7);
    check("two dimensional package", other::matrix[1][1], 37);
    check("struct element local", records[1], 16'h4567);
    check("struct element package", other::records[1], 16'h89ab);
    check("unpacked struct local x",plain[1].x,6);
    check("unpacked struct local y",plain[1].y,7);
    check("unpacked struct package x",other::plain[1].x,38);
    check("unpacked struct package y",other::plain[1].y,39);
    check("two dimensional unpacked struct local",plain_matrix[1][1].x,8);
    check("two dimensional unpacked struct package",other::plain_matrix[1][1].x,40);
    check("net local", wires[1], 9); check("net package", other::wires[1], 39);
    check("first child", c1, 11); check("second child", c2, 12);
    write_local(8); write_package(48);
    #1;
    check("task local", a[1], 8); check("task package", other::a[1], 48);
    check("task continuous local", ca, 8);
    $finish;
  end
endmodule
