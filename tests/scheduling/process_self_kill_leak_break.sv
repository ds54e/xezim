// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// Plain RTL with no subroutine call: a priority encoder with `break` in always_comb and in a clocked always.
// A fork child kills itself at t=12; the parent waits. The encoder must keep working.
module top;
  logic clk = 0;
  logic [7:0] req = 8'h00;
  int idx_c, valid_c, idx_q = 0, n_q = 0;
  always #5 clk = ~clk;
  always_comb begin
    idx_c = -1;
    for (int i = 0; i < 8; i++) begin
      if (req[i]) begin idx_c = i; break; end
    end
    valid_c = (idx_c >= 0);
  end
  always @(posedge clk) begin
    for (int i = 7; i >= 0; i--) begin
      if (req[i]) begin idx_q <= i; break; end
    end
    n_q <= n_q + 1;
    req <= req + 8'd5;
  end
  int bad = 0;
  always @(negedge clk) begin
    int exp;
    exp = -1;
    for (int i = 7; i >= 0; i--) if (req[i]) exp = i;
    if (idx_c !== exp || valid_c !== (exp >= 0)) bad++;
  end
  initial begin
    fork
      begin
        automatic process p = process::self();
        #12;
        p.kill();
      end
    join_none
    #103;
    if (bad == 0 && n_q == 10) $display("PASS encoder bad=%0d n_q=%0d", bad, n_q);
    else $display("FAIL encoder bad=%0d n_q=%0d expected 0 10", bad, n_q);
    $finish;
  end
endmodule
