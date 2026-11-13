// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// A process kills itself; the simulation then ends by $finish from a clocked always. The final block calls methods.
module top;
  logic clk = 0;
  int n = 0, f1 = 0, f2 = 0;
  class R;
    int total;
    function void add(int v); total += v; endfunction
    function int get(); return total; endfunction
  endclass
  R r = new;
  always #5 clk = ~clk;
  always @(posedge clk) begin
    n <= n + 1;
    if (n == 5) $finish;
  end
  initial begin
    automatic process p = process::self();
    #12;
    p.kill();
  end
  final begin
    r.add(3);
    f1 = 1;
    r.add(4);
    f2 = r.get();
    if (f1 == 1 && f2 == 7) $display("PASS final f1=%0d f2=%0d", f1, f2);
    else $display("FAIL final f1=%0d f2=%0d", f1, f2);
    $display("final done");
  end
endmodule
