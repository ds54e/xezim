// IEEE 1800-2023 §26.3: qualified references and imports refer to the owner.
// §6.8/§10.9.1: package variable patterns initialize before initial blocks.
// §8.3/§13.4: methods and subroutines use the declaring package scope.
package first;
  int a[0:1] = '{11, 12};
  int m[0:1][0:1] = '{'{1,2},'{3,4}};
  function int get(); return a[1]; endfunction
  task put(input int v); a[1] = v; endtask
  class reader;
    function int get(); return a[1]; endfunction
    function void put(input int v); a[1] = v; endfunction
  endclass
endpackage
package second;
  int a[0:1] = '{21, 22};
  int m[0:1][0:1] = '{'{5,6},'{7,8}};
  function int get(); return a[1]; endfunction
  task put(input int v); a[1] = v; endtask
endpackage
module imported(output int value);
  import second::a;
  assign value = a[1];
endmodule
module top;
  import second::*;
  first::reader r;
  int from_child;
  imported u(from_child);
  task check(input string label, input int got, expected);
    if (got === expected) $display("PASS %s", label);
    else $display("FAIL %s got=%0d expected=%0d", label, got, expected);
  endtask
  initial begin
    #1;
    check("first initializer", first::a[1], 12);
    check("second initializer", second::a[1], 22);
    check("import initializer", a[1], 22);
    check("first matrix initializer", first::m[1][1], 4);
    check("second matrix initializer", second::m[1][1], 8);
    first::put(31); second::put(41);
    r = new;
    #1;
    check("package function first", first::get(), 31);
    check("package function second", second::get(), 41);
    check("package method read", r.get(), 31);
    check("explicit import child", from_child, 41);
    r.put(51); a[1] = 61;
    #1;
    check("package method write", first::a[1], 51);
    check("wildcard import write", second::a[1], 61);
    check("import updated child", from_child, 61);
    $finish;
  end
endmodule
