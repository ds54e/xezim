`define CHK(n, pr) int n``_p=0, n``_f=0; assert property (pr) n``_p++; else n``_f++; initial #16 $display(`"n=%0d/%0d`", n``_p, n``_f);
// 26.3: a local declaration hides a wildcard-imported name. `s` and `t` in the assertions
// are the module's signals, not the package's sequences.
package pk;
  sequence s(x=0); x; endsequence      // every formal has a default
  sequence t; 0; endsequence           // control: no formals
  sequence u(x); x; endsequence        // control: formal without a default
endpackage
module top;
  import pk::*;
  bit clk=0;
  bit s=1, t=1, u=1;
  always #5 clk=~clk;
  `CHK(signal_named_like_default_seq, @(posedge clk) s)        // 2/0
  `CHK(signal_named_like_portless_seq, @(posedge clk) t)       // 2/0
  `CHK(signal_named_like_formal_seq, @(posedge clk) u)         // 2/0
  initial #17 $finish;
endmodule
