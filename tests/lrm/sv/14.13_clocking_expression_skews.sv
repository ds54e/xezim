// top: top
// §14.4, §14.5, §14.13: #0 samples after NBA; #1step and #1 sample
// before the edge. Stimulus at t=4.5 distinguishes #1 from #1step.
`timescale 1ns/1ps
module top;
  bit clk = 0;
  int a = 3;
  always #5 clk = ~clk;
  always @(posedge clk) a <= 9;
  clocking cb @(posedge clk);
    input implicit_step = a + 1;
    input #1step step_value = a + 1;
    input #0 observed = a + 1;
    input #1 earlier = a + 1;
    input a;
  endclocking
  initial begin
    #4.5 a = 7;
    @(cb); #1;
    $display("T|skew|default=%0d step=%0d zero=%0d one=%0d direct=%0d", cb.implicit_step, cb.step_value, cb.observed, cb.earlier, cb.a);
    a = 12;
    #1;
    $display("T|held|default=%0d zero=%0d", cb.implicit_step, cb.observed);
    $finish;
  end
endmodule
