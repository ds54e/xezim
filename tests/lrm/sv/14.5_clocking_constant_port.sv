// top: top
// §14.5, §14.13, §23.3.3.2: a constant input-port actual is sampled as 5.
`timescale 1ns/1ns
module leaf(input bit clk, input int pi);
  clocking cb @(posedge clk);
    input d_pi = pi;
  endclocking
endmodule
module top;
  bit clk = 0;
  always #5 clk = ~clk;
  leaf l1(clk, 5);
  initial begin
    @(l1.cb);
    #1;
    $display("T|constant-port|value=%0d", l1.cb.d_pi);
    $finish;
  end
endmodule
