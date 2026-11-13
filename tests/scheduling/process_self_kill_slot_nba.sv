// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// The killed process raises clk with a nonblocking assignment and kills itself in the same time step.
// The clocked always triggered by that update is another process: it must run whole.
module top;
  logic clk = 0;
  int e = 0, k = 0;
  logic [7:0] d = 8'h5a, q1 = 0, q2 = 0;
  function automatic logic [7:0] rev(input logic [7:0] v);
    for (int i = 0; i < 8; i++) rev[i] = v[7 - i];
  endfunction
  always @(posedge clk) begin
    for (int i = 0; i < 8; i++) if (d[i]) begin k = i; break; end
    q1 <= rev(d);
    q2 <= d;
    e = e + 1;
  end
  initial begin
    fork
      begin
        automatic process p = process::self();
        #3;
        clk <= 1;
        p.kill();
      end
    join_none
    #10;
    if (e == 1 && q1 == 8'h5a && q2 == 8'h5a && k == 1) $display("PASS nba_edge"); else $display("FAIL nba_edge e=%0d q1=%h q2=%h k=%0d", e, q1, q2, k);
  end
endmodule
