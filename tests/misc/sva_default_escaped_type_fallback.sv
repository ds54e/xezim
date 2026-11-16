// §16.8.1/§16.12.18: an escaped typedef still makes the formal one bit.
module top;
  typedef bit \one.bit ;
  bit clk=0;
  int passes=0, failures=0;
  always #5 clk=~clk;
  property p(\one.bit x=2, y=2); @(posedge clk) y; endproperty
  assert property(p()) passes++; else failures++;
  initial begin #16; $display("escaped-type=%0d/%0d",passes,failures);
    if(passes!=0 || failures!=2) $fatal(1,"escaped type");
    $display("PASS"); $finish;
  end
endmodule
