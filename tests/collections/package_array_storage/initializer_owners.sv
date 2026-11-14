// IEEE 1800-2023 §6.8, §26.3: static initializers see package declarations.
package p;
  int a[2]; // default zeros; no ordering between static initializers
  int m[2][2]='{'{a[0]+37,a[1]+38},'{a[1]+38,a[0]+37}};
  int n=a.sum()+75;
endpackage
module top;
  int a[2]='{5,6}; int m[2][2]; int n;
  initial begin #1;
    if(p::m[0][0]===37 && p::m[1][0]===38 && p::n===75 && a[0]===5 && m[0][0]===0)
      $display("PASS initializer owners");
    else $display("FAIL initializer owners %0d %0d %0d %0d %0d",p::m[0][0],p::m[1][0],p::n,a[0],m[0][0]);
    $finish;
  end
endmodule
