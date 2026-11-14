// §26.3: an explicit import with no conflicting declaration is legal.
package first; int a[0:1]; endpackage
package second; int a[0:1]; endpackage
module top;
  import second::a;
  int value, index;
  assign value=a[index];
  initial begin
    #1 first::a[1]=6; a[1]=38; index=1;
    #1;
    if (first::a[1] === 6) $display("PASS explicit other owner"); else $display("FAIL explicit other owner");
    if (second::a[1] === 38) $display("PASS explicit imported owner"); else $display("FAIL explicit imported owner");
    if (value === 38) $display("PASS explicit continuous"); else $display("FAIL explicit continuous %0d",value);
    $finish;
  end
endmodule
