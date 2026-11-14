// IEEE 1800-2023 §26.3 and §7.12: the selected package owns the receiver.
package p; int a[0:2]; endpackage
module top;
 int a[0:2]; int q[$];
 initial begin
 #1 a='{5,6,7}; p::a='{38,37,39};
 #1 q=p::a.find() with (item>30); $display("OBS find size=%0d first=%0d",q.size(),q[0]);
 p::a.sort(); #1 $display("OBS sort local=%0d/%0d/%0d package=%0d/%0d/%0d",a[0],a[1],a[2],p::a[0],p::a[1],p::a[2]);
 p::a.reverse(); #1 $display("OBS reverse local=%0d/%0d/%0d package=%0d/%0d/%0d",a[0],a[1],a[2],p::a[0],p::a[1],p::a[2]);
 if(a[0]===5 && a[1]===6 && a[2]===7 && p::a[0]===39 && p::a[1]===38 && p::a[2]===37) $display("PASS isolated ordering"); else $display("FAIL isolated ordering");
 $finish;
 end
 initial #100 $finish;
endmodule
