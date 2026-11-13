// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// The clock comes from `always #5 clk = ~clk`. A clocked always kills process::self() once.
// The testbench process (waiting in a delay) and a second clocked always are different processes.
`timescale 1ns/1ps
module top;
  bit clk;
  int a_x, a_after, b_y, tb_done;
  class C; int k; function int g(int v); k = v; return v + 1; endfunction endclass
  C o = new;
  always #5 clk = ~clk;
  always @(posedge clk) begin
    automatic process p = process::self();
    a_x++;
    if (a_x == 2) p.kill();
    a_after++;
  end
  always @(posedge clk) begin
    void'(o.g(1));
    b_y++;
  end
  initial begin
    #52;
    tb_done = 1;
    $display("INFO a_x=%0d a_after=%0d clk_toggling=%0d", a_x, a_after, 1);
    if (b_y == 5) $display("PASS block_b"); else $display("FAIL block_b b_y=%0d expected 5", b_y);
    $finish;
  end
  final begin
    if (tb_done) $display("PASS tb_alive"); else $display("FAIL tb_alive a_x=%0d a_after=%0d b_y=%0d", a_x, a_after, b_y);
  end
  initial #200 $finish;
endmodule
