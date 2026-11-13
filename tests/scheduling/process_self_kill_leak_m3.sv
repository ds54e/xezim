// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// As leak_m1, but the self-kill is in a fork child and the testbench keeps running (#delays in the parent).
module top;
  logic clk = 0;
  int b = 0;
  class C; int k; function int g(int v); k = v; return v + 1; endfunction endclass
  C o = new;
  always #5 clk = ~clk;
  always @(posedge clk) begin
    void'(o.g(1));
    b = b + 1;
  end
  initial begin
    fork
      begin
        automatic process p = process::self();
        #12;
        p.kill();
      end
    join_none
    #100;
    if (b == 10) $display("PASS b=%0d", b);
    else $display("FAIL b=%0d expected 10", b);
    $finish;
  end
endmodule
