// IEEE 1800-2023 §7.2, §7.4, §26.3: selections keep their package root.
package p; typedef struct { int x; } T; T a[2][2]; int m[2][2][2]; endpackage
module top;
  p::T a[2][2]; int m[2][2][2]; int x, y;
  assign x=p::a[1][1].x; assign y=p::m[1][1][1];
  initial begin #1; p::a[1][1].x=10; p::m[1][1][1]=20; #1;
    if(x===10 && y===20 && a[1][1].x===0 && m[1][1][1]===0)
      $display("PASS deep members");
    else $display("FAIL deep members %0d %0d %0d %0d",x,y,a[1][1].x,m[1][1][1]);
    $finish;
  end
endmodule
