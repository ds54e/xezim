// §27.4, §23.3.2, §25.3, §10.3.2: selected scopes and an interface.
`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input S x[2]); return int'($time); endfunction
module unit;
 S a[2]; int r; assign r=f(.x(a));
endmodule
interface bus;
 S a[2]; int r; assign r=f(.x(a));
endinterface
module top;
 unit u[2](); bus b();
 for(genvar k=0;k<2;k++) begin:g
  S a[2]; int r; assign r=f(.x(a));
 end
 initial begin
 #1 g[1].a[0].v=7;
 #1 $display("T|gen %0d %0d %0d %0d %0d",g[0].r,g[1].r,u[0].r,u[1].r,b.r);
 #1 u[1].a[0].v=11;
 #1 $display("T|inst %0d %0d %0d %0d %0d",g[0].r,g[1].r,u[0].r,u[1].r,b.r);
 #1 b.a[0].v=13;
 #1 $display("T|iface %0d %0d %0d %0d %0d",g[0].r,g[1].r,u[0].r,u[1].r,b.r);
 $finish;end
endmodule
