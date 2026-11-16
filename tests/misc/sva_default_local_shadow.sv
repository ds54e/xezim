`define CHK(n, pr) int n``_p=0, n``_f=0; assert property (pr) n``_p++; else n``_f++; initial #16 $display(`"n=%0d/%0d`", n``_p, n``_f);
// 16.10: an assertion local variable (or a formal) may have the name of a sequence
// declared in the enclosing scope; inside the property the name is the variable.
module top;
  bit clk=0, a=0;
  always #5 clk=~clk;
  sequence s(x=a); x; endsequence          // every formal has a default
  sequence t; a; endsequence               // control: no formals (main already expands a bare name)
  property lv_s; int s; @(posedge clk) (1, s = 1) |-> (s == 1); endproperty   // 2/0
  property lv_t; int t; @(posedge clk) (1, t = 1) |-> (t == 1); endproperty   // 2/0
  property formal_s(s); @(posedge clk) s; endproperty                         // formal named s
  `CHK(local_named_like_default_seq, lv_s)
  `CHK(local_named_like_portless_seq, lv_t)
  `CHK(formal_named_like_default_seq, formal_s(1'b1))
  initial #17 $finish;
endmodule
