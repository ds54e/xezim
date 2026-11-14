// IEEE 1800-2023 §26.3, §7.4, §7.12: references retain their package owner.
package other; int a[0:2] = '{3, 1, 2}; endpackage
module top;
  int a[0:2];
  int q[$];
  initial begin
    #1;
    if (other::a.sum() === 6) $display("PASS sum"); else $display("FAIL sum %0d", other::a.sum());
    if (other::a.max()[0] === 3) $display("PASS max"); else $display("FAIL max %p", other::a.max());
    q = other::a.find with (item > 1);
    if (q.size() === 2) $display("PASS find"); else $display("FAIL find %p", q);
    other::a.sort();
    if (other::a[0] === 1 && other::a[2] === 3) $display("PASS sort"); else $display("FAIL sort %p (module array %p)", other::a, a);
    other::a.reverse();
    if (other::a[0] === 3 && other::a[2] === 1) $display("PASS reverse"); else $display("FAIL reverse %p (module array %p)", other::a, a);
    $finish;
  end
endmodule
