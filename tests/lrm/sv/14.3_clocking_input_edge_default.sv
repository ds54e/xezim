// top: top
// §14.3, §14.13: an input edge skew samples at the preceding clock edge.
// At t=10 (negedge), a+1 is 8; the t=12 change must not affect that sample.
`timescale 1ns/1ns
module top;
  bit clk = 0;
  int a = 3, edge_value = 8;
  always #5 clk = ~clk;
  clocking cb @(posedge clk);
    default input negedge;
    input edge_value = a + 1;
  endclocking
  initial begin
    #7 a = 7;
    #5 a = 12;
    @(cb);
    #1;
    $display("T|edge|value=%0d", cb.edge_value);
    $finish;
  end
endmodule
