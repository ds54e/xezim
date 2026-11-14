// IEEE 1800-2023 §26.3, §7.4, §7.12: references retain their package owner.
package other;
  typedef struct { int x; int y; } st_t;
  int a[0:2] = '{3, 1, 2}; int m[0:1][0:1] = '{'{1,2},'{3,4}}; st_t st[0:1]; logic [7:0] mem[0:2]; byte by[0:3]; int r[0:2];
endpackage
module top;
  int a[0:2]; int m[0:1][0:1]; other::st_t st[0:1]; logic [7:0] mem[0:2]; byte by[0:3]; int r[0:2];
  other::st_t s1; int t, ok; int packed32; string str;
  logic clk = 0; int ff;
  always_ff @(posedge clk) ff <= other::a[0] + other::m[1][1];
  function automatic int f(); return other::a[2] * 2; endfunction
  int y; assign y = f() + other::a[1];
  initial begin
    #1 other::a[1]++; other::a[2] += 5; other::m[0][0] <= 9; other::st[1] = '{7, 8}; other::st[0].x <= 4;
    $readmemh("tests/collections/package_array_storage/mem3.hex", other::mem);
    other::by = '{8'h11, 8'h22, 8'h33, 8'h44};
    #1 s1 = other::st[1]; packed32 = {>>{other::by}}; str = $sformatf("%p", other::m);
    ok = std::randomize(t) with { t inside {other::a}; };
    $display("incr %p (exp '{3, 2, 7}) nba %0d %0d (exp 9 4) pattern %0d %0d / %p (exp 7 8)", other::a, other::m[0][0], other::st[0].x, s1.x, s1.y, other::st[1]);
    $display("readmem %h %h %h (exp 0a 0b 0c) stream %h (exp 11223344) sformat %s inside=%0d", other::mem[0], other::mem[1], other::mem[2], packed32, str, t inside {other::a});
    $display("y=%0d (exp 16)", y);
    clk = 1; #1 $display("ff=%0d (exp 7)", ff);
    foreach (other::r[i]) other::r[i] = other::a[i] * 10;
    $display("foreach %p (exp '{30, 20, 70}) eq=%0d neq=%0d (exp 0 1)", other::r, other::a == other::r, other::a != other::r);
    $display("module arrays untouched: %p %p %p %p %p", a, m, st, mem, r);
    if (other::a[0] === 3 && other::a[1] === 2 && other::a[2] === 7 &&
        other::m[0][0] === 9 && other::st[0].x === 4 && s1.x === 7 && s1.y === 8 &&
        other::mem[0] === 8'h0a && other::mem[1] === 8'h0b && other::mem[2] === 8'h0c &&
        packed32 === 32'h11223344 && y === 16 && (t inside {other::a}) &&
        other::r[0] === 30 && other::r[1] === 20 && other::r[2] === 70 &&
        a[0] === 0 && m[0][0] === 0 && st[0].x === 0 && r[0] === 0)
      $display("PASS selected consumers"); else $display("FAIL selected consumers");
    if (ff === 7) $display("PASS ff"); else $display("FAIL ff");
    $finish;
  end
endmodule
