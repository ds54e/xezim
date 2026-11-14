// IEEE 1800-2023 §26.3/§26.5: an explicit local declaration wins over
// a wildcard import. §8.3: a class declared in the module sees that scope.
package other; int a[0:1]; int lone[0:1]; endpackage
module top;
  import other::*;
  int a[0:1];
  int local_value, package_value, index;
  assign local_value = a[1];
  assign package_value = other::lone[index];
  class reader;
    function int get(); return a[1]; endfunction
    function void put(input int v); a[1] = v; endfunction
  endclass
  reader r;
  task check(input string label, input int got, expected);
    if (got === expected) $display("PASS %s", label);
    else $display("FAIL %s got=%0d expected=%0d", label, got, expected);
  endtask
  initial begin
    #1 index=1; a[1]=6; other::a[1]=38; other::lone[1]=17; r=new;
    #1;
    check("wildcard local read", a[1], 6);
    check("wildcard local continuous", local_value, 6);
    check("qualified only array", package_value, 17);
    check("module method read", r.get(), 6);
    r.put(9);
    #1;
    check("module method write", a[1], 9);
    check("module method package guard", other::a[1], 38);
    $finish;
  end
endmodule
