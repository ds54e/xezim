// §7.5/§7.10 and §26.3: dynamic collections keep their existing path.
// Assert only LRM-correct results; aliasing observations remain probes.
package other; int a[]; int q[$]; endpackage
module top;
  int a[]; int q[$];
  initial begin
    #1 a=new[2]; other::a=new[3]; a[1]=6; other::a[1]=38;
    q.push_back(7); other::q.push_back(39);
    #1;
    if (other::a.size() === 3) $display("PASS package dynamic size"); else $display("FAIL package dynamic size");
    if (other::a[1] === 38) $display("PASS package dynamic value"); else $display("FAIL package dynamic value");
    if (q[0] === 7) $display("PASS module queue first value"); else $display("FAIL module queue first value");
    $display("OBS dynamic local=%0d/%0d package=%0d/%0d queue local=%0d/%0d package=%0d/%0d",a.size(),a[1],other::a.size(),other::a[1],q.size(),q[0],other::q.size(),other::q[0]);
    $finish;
  end
endmodule
