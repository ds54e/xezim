// §16.8/§9.4.2.3: the event default's iff condition suppresses every tick.
module top;
  bit clk=0;
  int passes=0, failures=0;
  always #5 clk=~clk;
  property p(event c=clk iff 0); @(c) 1; endproperty
  assert property(p()) passes++; else failures++;
  initial begin #16; $display("event-iff=%0d/%0d",passes,failures);
    if(passes!=0 || failures!=0) $fatal(1,"event iff");
    $display("PASS"); $finish;
  end
endmodule
