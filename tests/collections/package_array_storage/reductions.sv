// IEEE 1800-2023 §26.3 and §7.12: the selected package owns the receiver.
package p; int a[0:1]; endpackage
module top;
 int a[0:1];
 initial begin
 #1 a='{5,6}; p::a='{37,38};
 #1 $display("OBS local=%0d/%0d package=%0d/%0d",a[0],a[1],p::a[0],p::a[1]);
 $display("OBS reductions package=%0d/%0d/%0d/%0d/%0d",p::a.sum(),p::a.product(),p::a.and(),p::a.or(),p::a.xor());
 if(p::a.sum()===75) $display("PASS package sum"); else $display("FAIL package sum");
 if(p::a.product()===1406 && p::a.and()===36 && p::a.or()===39 && p::a.xor()===3) $display("PASS package reductions"); else $display("FAIL package reductions");
 $finish;
 end
 initial #100 $finish;
endmodule
