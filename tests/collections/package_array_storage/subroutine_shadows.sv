// IEEE 1800-2023 §23.9, §26.3: local and package subroutines have distinct scopes.
package p;
  int a[2];
  function int put(int v); a[1]=v; return a[1]; endfunction
  task set0(int v); a[0]=v; endtask
endpackage
module top;
  int a[2]; int ignored;
  function int put(int v); a[1]=v; return a[1]; endfunction
  task set0(int v); a[0]=v; endtask
  initial begin
    #1 ignored=put(6); ignored=p::put(38); set0(5); p::set0(37);
    #1;
    if(a[0]===5 && a[1]===6 && p::a[0]===37 && p::a[1]===38)
      $display("PASS subroutine shadows");
    else $display("FAIL subroutine shadows %0d %0d %0d %0d",a[0],a[1],p::a[0],p::a[1]);
    $finish;
  end
endmodule
