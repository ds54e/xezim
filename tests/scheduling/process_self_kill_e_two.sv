// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// Three clocked always blocks on the same clock. Block A kills process::self() on its first activation.
// Block B is a different process: it must run whole on every edge.
`timescale 1ns/1ps
module top;
  bit clk;
  int a_x, a_after, b_x, b_y, c_x;
  class C; int k; function int g(int v); k = v; return v + 1; endfunction endclass
  C o = new;
  function automatic int fs(int v); string t; t = $sformatf("%0d", v); return t.len() + v; endfunction
  always @(posedge clk) begin
    automatic process p = process::self();
    a_x++;
    if (a_x == 1) p.kill();
    a_after++;
  end
  always @(posedge clk) begin
    b_x = o.g(b_x);
    b_y++;
  end
  always @(posedge clk) begin
    void'(fs(1));
    c_x++;
  end
  // An independent falling-edge driver keeps all three rising edges even
  // with the existing borrowed process identity in optimized edge blocks.
  initial begin #1; clk = 1; end
  initial begin #2; clk = 0; end
  initial begin #3; clk = 1; #1; clk = 0; end
  initial begin #5; clk = 1; #1; clk = 0; end
  initial begin
    #20;
    $display("INFO a_x=%0d a_after=%0d", a_x, a_after);
    if (b_x == 3 && b_y == 3) $display("PASS block_b"); else $display("FAIL block_b b_x=%0d b_y=%0d expected 3 3", b_x, b_y);
    if (c_x == 3) $display("PASS block_c"); else $display("FAIL block_c c_x=%0d expected 3", c_x);
    $finish;
  end
endmodule
