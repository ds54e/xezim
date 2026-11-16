// §16.8.1/§16.12.18: LRM-correct guard for supplied named actuals, which
// this change declines. Main reaches this value without binding by name.
module top;
  bit clk=0;
  int passes=0, failures=0;
  always #5 clk=~clk;
  property p(bit x=1, int y=0); @(posedge clk) x; endproperty
  assert property(p(.y(0),.x(2))) passes++; else failures++;
  initial begin #16; $display("named-typed=%0d/%0d",passes,failures);
    if(passes!=0 || failures!=2) $fatal(1,"named typed");
    $display("PASS"); $finish;
  end
endmodule
