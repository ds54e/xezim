// §16.8/§26.3: a local signal hides an imported sequence even when the
// assertion uses its scope's default clock rather than an explicit clock.
package bare_checks;
  sequence s(x=1); x; endsequence
endpackage
module top;
  import bare_checks::*;
  bit clk=0, s=0;
  int passes=0, failures=0;
  always #5 clk=~clk;
  default clocking cb @(posedge clk); endclocking
  assert property(s) passes++; else failures++;
  initial begin #16;
    $display("bare-shadow=%0d/%0d",passes,failures);
    $finish;
  end
endmodule
