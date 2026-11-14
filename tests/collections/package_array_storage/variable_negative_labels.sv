// IEEE 1800-2023 §26.3, §7.4, §7.12: references retain their package owner.
package other; int c[-2:1]; endpackage
module top;
  int c[-2:1];
  int i = 0, cc, pc;
  assign cc = other::c[i];
  always_comb pc = other::c[i];
  initial begin
    #1 other::c[-2] = 50; other::c[-1] = 51; other::c[0] = 52; other::c[1] = 53;
    #1 i = -2; #1 $display("i=-2 assign=%0d comb=%0d proc=%0d (exp 50)", cc, pc, other::c[i]);
    if (cc === 50 && pc === 50 && other::c[i] === 50) $display("PASS label 50"); else $display("FAIL label 50");
    #1 i = -1; #1 $display("i=-1 assign=%0d comb=%0d proc=%0d (exp 51)", cc, pc, other::c[i]);
    if (cc === 51 && pc === 51 && other::c[i] === 51) $display("PASS label 51"); else $display("FAIL label 51");
    #1 i = 1;  #1 $display("i=1 assign=%0d comb=%0d proc=%0d (exp 53)", cc, pc, other::c[i]);
    if (cc === 53 && pc === 53 && other::c[i] === 53) $display("PASS label 53"); else $display("FAIL label 53");
    $finish;
  end
endmodule
