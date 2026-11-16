// IEEE 1800-2023 16.8 (sequence_actual_arg ::= event_expression | sequence_expr | $), 9.4.2.3:
// an untyped formal used as the clocking event; its default is `clk iff en`.
// en stays 0, so the event never occurs: no attempt, no pass, no failure.
module top;
  bit clk=0, en=0, a=0;
  int dp=0, df=0, up=0, uf=0;
  always #5 clk=~clk;
  property p(c=clk iff en); @(c) a; endproperty
  assert property (p()) dp++; else df++;
  property u(untyped c=(clk iff en)); @(c) a; endproperty
  assert property (u()) up++; else uf++;
  initial begin
    #16 $display("default=%0d/%0d", dp, df);
    $display("untyped=%0d/%0d", up, uf);
    if (dp!=0 || df!=0 || up!=0 || uf!=0) $fatal(1, "FAIL");
    $display("PASS"); $finish;
  end
endmodule
