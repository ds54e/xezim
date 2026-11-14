// §23.9: an instance named like a package still owns its hierarchical array.
package other; int a[0:1]; endpackage
module kid;
  int a[0:1]; initial #1 a[1]=17;
endmodule
module top;
  int a[0:1]; int observed;
  kid other();
  assign observed=other.a[1];
  initial begin
    #1 a[1]=6;
    #1 $display("OBS instance package name child=%0d direct=%0d local=%0d",observed,other.a[1],a[1]);
    if (observed === 17 && other.a[1] === 17 && a[1] === 6) $display("PASS instance package name guard");
    else $display("FAIL instance package name guard");
    $finish;
  end
endmodule
