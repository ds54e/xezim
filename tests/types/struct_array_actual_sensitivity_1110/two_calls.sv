// §10.3.2: either actual changing re-evaluates the whole expression.
`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input S x[2]); return int'($time); endfunction
module top;
 S a[2], b[2]; int r;
 assign r=f(.x(a))+f($root.top.b);
 initial begin
 #1 a[0].v=7;
 #1 $display("T|a %0d",r);
 #1 b[1].v=11;
 #1 $display("T|b %0d",r);
 $finish;
 end
endmodule
