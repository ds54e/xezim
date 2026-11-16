// top: top
// §14.3, §14.5, §14.13: input expressions keep their self-determined
// integral types (§11.6, §11.8); read after the sampled event (§14.10).
`timescale 1ns/1ns
module source;
  int a = 11;
endmodule
module top;
  bit clk = 0;
  int a = 3, sum = 99;
  logic signed [7:0] neg = -4;
  logic [7:0] u = 8'h80;
  logic [79:0] wide = 80'h80000000000000000001;
  logic [3:0] xz = 4'b10xz;
  source child();
  always #5 clk = ~clk;
  clocking cb @(posedge clk);
    input a;
    input sum = a + 1;
    input cat = {a, 1'b0};
    input signed_sum = neg + 1;
    input mixed = neg + u;
    input big = wide + 80'd2;
    input states = {xz, 1'bz};
    input nonzero = u != 0;
    input repeated = {2{u}};
    input constant_value = 32'd4;
    input slice = u[7:4];
    input hier = child.a;
  endclocking
  initial begin
    @(cb); #1;
    $display("T|expr|a=%0d sum=%0d cat=%0d signed=%0d mixed=%0d", cb.a, cb.sum, cb.cat, cb.signed_sum, cb.mixed);
    $display("T|types|big=%h states=%b nonzero=%b", cb.big, cb.states, cb.nonzero);
    $display("T|constant|rep=%h value=%0d", cb.repeated, cb.constant_value);
    $display("T|guard|slice=%h hier=%0d", cb.slice, cb.hier);
    $finish;
  end
endmodule
