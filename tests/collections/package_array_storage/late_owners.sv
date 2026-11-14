// IEEE 1800-2023 §9.2.3, §18.5, §24, §26.3: all executable owners use the package array.
package p;
  int a[2];
  class C;
    rand int v;
    constraint value_c { v == a[1]; }
    int init_value=a[0];
  endclass
endpackage
module top;
  int a[2]; p::C c; bit ok;
  initial begin
    #1 p::a='{37,38}; c=new; ok=c.randomize();
    #1;
    if(ok && c.v===38 && c.init_value===37) $display("PASS class expressions");
    else $display("FAIL class expressions %0d %0d %0d",ok,c.v,c.init_value);
    #3 $finish;
  end
  final begin
    if(p::a.sum()===75 && a[0]===0) $display("PASS final owner");
    else $display("FAIL final owner %0d %0d",p::a.sum(),a[0]);
  end
endmodule
