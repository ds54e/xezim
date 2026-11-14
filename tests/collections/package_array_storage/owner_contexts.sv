// IEEE 1800-2023 §26.3, §6.21, §7.12: package ownership and local shadowing.
package p;
  int a[0:1];
  // Read default zeros, independent of static initializer order.
  int b[0:1] = '{a[0]+37,a[1]+38};
  function automatic int total(); return a.sum; endfunction
  function automatic int shadow(); int a[0:1]='{2,3}; return a.sum(); endfunction
  task put(int v); a[1]=v; endtask
  class C;
    function int sum(); return a.sum() with (item+1); endfunction
  endclass
endpackage
module top;
  int a[0:1] = '{5,6}; int b[0:1]; p::C c;
  initial begin
    c=new;
    #1; p::a='{37,38};
    if(p::total()===75 && p::shadow()===5 && c.sum()===77) $display("PASS body owners"); else $display("FAIL body owners %0d %0d %0d",p::total(),p::shadow(),c.sum());
    if(p::b[0]===37 && p::b[1]===38) $display("PASS initializer owner"); else $display("FAIL initializer owner");
    p::put(42);
    #1;
    if(a[1]===6 && p::a[1]===42) $display("PASS task owner"); else $display("FAIL task owner");
    $finish;
  end
endmodule
