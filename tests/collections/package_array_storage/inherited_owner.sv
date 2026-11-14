// IEEE 1800-2023 §8.3, §26.3: inherited members shadow package names.
package p;
  int a[2] = '{37,38};
  class B; int x; endclass
  class D extends B;
    function int total(); return a.sum(); endfunction
  endclass
  class S; int a[2]; endclass
  class T extends S;
    function int total(); a[0]=2; a[1]=3; return a.sum(); endfunction
  endclass
endpackage
module top;
  int a[2]='{5,6}; p::D d; p::T t;
  initial begin d=new; t=new; #1;
    if(d.total()===75 && t.total()===5 && a[0]===5 && p::a[0]===37)
      $display("PASS inherited owners");
    else $display("FAIL inherited owners %0d %0d %0d %0d",d.total(),t.total(),a[0],p::a[0]);
    $finish;
  end
endmodule
