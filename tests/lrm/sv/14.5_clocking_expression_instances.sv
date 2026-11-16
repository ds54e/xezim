// top: top
// §14.5, §14.6, §14.13: instance-local expression inputs and two blocks.
// §14.11, §14.12: default clocking cycle delay. §14.16: output skew.
`timescale 1ns/1ns
interface bus(input bit clk);
  int a;
  clocking cb @(posedge clk);
    input sum = a + 1;
    input cat = {a, 1'b0};
  endclocking
endinterface
module leaf(input bit clk);
  int a = 21;
  clocking cb @(posedge clk);
    input sum = a + 1;
  endclocking
endmodule
module top;
  bit clk = 0;
  int a = 3, q = 0, r = 0;
  bus b(clk), c(clk);
  leaf child(clk);
  always #5 clk = ~clk;
  default clocking cb @(posedge clk);
    input a;
    input sum = a + 1;
    output q;
    output #2 r;
  endclocking
  clocking other @(posedge clk);
    input a;
    input sum = a + 1;
  endclocking
  initial begin
    b.a = 3;
    c.a = 7;
    @(cb);
    cb.q <= 9;
    cb.r <= 9;
    #1;
    $display("T|instance|b=%0d c=%0d cat=%0d child=%0d", b.cb.sum, c.cb.sum, c.cb.cat, child.cb.sum);
    $display("T|two|a=%0d/%0d expr=%0d/%0d", cb.a, other.a, cb.sum, other.sum);
    $display("T|output|q=%0d r=%0d", q, r);
    #2;
    $display("T|delayed|q=%0d r=%0d", q, r);
    ##2;
    #1;
    $display("T|cycle|time=%0t sum=%0d", $time, cb.sum);
    $finish;
  end
endmodule
