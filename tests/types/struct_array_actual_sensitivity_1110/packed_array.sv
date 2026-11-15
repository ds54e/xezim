// §7.2.1, §10.3.2: arrays of packed structures keep their ordinary path.
`timescale 1ns/1ps
typedef struct packed { logic signed [7:0] v; logic [3:0] tag; } S;
function automatic int f(input S x[2]); return int'($time); endfunction
module top;
 S a[2]; int p,n,r,t;
 assign p=f(a); assign n=f(.x(a)); assign r=f($root.top.a); assign t=f(top.a);
 initial begin
 #1 a[1].v=-7;
 #1 $display("T|member %0d %0d %0d %0d",p,n,r,t);
 #1 a[0]='{8'hxz,4'hf};
 #1 $display("T|whole %0d %0d %0d %0d",p,n,r,t);
 $finish;end
endmodule
