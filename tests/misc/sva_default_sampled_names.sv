// §16.5.1/§16.8: a default reads the same sampled value as an explicit actual.
package sampled_defaults;
  bit value=0;
endpackage
module top;
  bit clk=0, e=0, a=1;
  int pp=0, pf=0, cp=0, cf=0, bp=0, bf=0, ep=0, ef=0;
  always #5 clk=~clk;
  always @(posedge clk) begin e <= ~e; sampled_defaults::value <= ~sampled_defaults::value; end
  clocking cb @(posedge clk); input a; endclocking
  property p(x=sampled_defaults::value); @(posedge clk) x == e; endproperty
  property b(x=cb.a); @(posedge clk) x; endproperty
  assert property(p()) pp++; else pf++;
  assert property(p(sampled_defaults::value)) cp++; else cf++;
  assert property(b()) bp++; else bf++;
  assert property(b(cb.a)) ep++; else ef++;
  initial begin #16;
    $display("package=%0d/%0d control=%0d/%0d",pp,pf,cp,cf);
    $display("clocking=%0d/%0d control=%0d/%0d",bp,bf,ep,ef);
    $finish;
  end
endmodule
