// §16.8/§16.12 and §26.3: defaults resolve in the declaring package.
package checks;
  parameter bit value=1;
  sequence s(x=value); x; endsequence
endpackage
module top;
  import checks::*;
  parameter bit value=0;
  bit clk=0;
  int passes=0, failures=0;
  always #5 clk=~clk;
  assert property(@(posedge clk) s()) passes++; else failures++;
  initial begin #16; $display("package-shadow=%0d/%0d",passes,failures);
    if(passes!=2 || failures!=0) $fatal(1,"package shadow");
    $display("PASS"); $finish;
  end
endmodule
