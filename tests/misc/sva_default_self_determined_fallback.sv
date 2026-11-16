// §16.8: the untyped sum is one bit before substitution, so 1+1 is zero.
// Guard the LRM-correct value of the declined arithmetic-default path.
module top;
  bit clk=0, a=1, b=1;
  int passes=0, failures=0;
  always #5 clk=~clk;
  property p(x=a+b); @(posedge clk) x == 2; endproperty
  assert property(p()) passes++; else failures++;
  initial begin #16;
    $display("self-determined=%0d/%0d", passes, failures);
    $finish;
  end
endmodule
