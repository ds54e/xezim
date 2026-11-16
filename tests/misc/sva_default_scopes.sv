// IEEE 1800-2023 §16.8/§16.12: declaration scope and live default expressions.
package checks;
  parameter bit expected=1;
  sequence pkg_seq(x=expected); x; endsequence
endpackage
module child(input bit clk, input bit a);
  int passes=0, failures=0;
  property p(x=a); @(posedge clk) x; endproperty
  assert property (p()) passes++; else failures++;
  initial begin
    #16; $display("child=%0d/%0d",passes,failures);
    if (passes!=1 || failures!=1) $fatal(1,"child");
  end
endmodule
interface monitor(input bit clk, input bit a);
  int passes=0, failures=0;
  property p(x=a); @(posedge clk) x; endproperty
  assert property (p()) passes++; else failures++;
  initial begin
    #16; $display("interface=%0d/%0d",passes,failures);
    if (passes!=1 || failures!=1) $fatal(1,"interface");
  end
endinterface
module top;
  import checks::*;
  bit clk=0, a=0;
  always #5 clk=~clk;
  initial #10 a=1;
  child c(clk,a);
  monitor m(clk,a);
  int pkg_passes=0;
  assert property (@(posedge clk) pkg_seq()) pkg_passes++;
  for (genvar g=0;g<2;g++) begin: gen
    bit local_value=1;
    int passes=0;
    property p(x=local_value); @(posedge clk) x; endproperty
    assert property(p()) passes++;
    initial begin
      #16; $display("generate%0d=%0d",g,passes);
      if(passes!=2) $fatal(1,"generate");
    end
  end
  initial begin
    #17; $display("package=%0d",pkg_passes);
    if(pkg_passes!=2) $fatal(1,"package");
    $display("PASS"); $finish;
  end
endmodule
