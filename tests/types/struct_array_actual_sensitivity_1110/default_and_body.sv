// §13.5.3, §10.3.2: retain existing default and callee-body dependencies.
`timescale 1ns/1ps
typedef struct { int v; } S;
module top;
 S a[2]; int bias, hidden, unrelated, r;
 function automatic int f(input S x[2], input int offset=bias);
   return int'($time)+offset+hidden;
 endfunction
 assign r=f(.x(a));
 initial begin
 #1 a[0].v=7; bias=2; hidden=0;
 #1 $display("T|array %0d",r);
 #1 bias=5;
 #1 $display("T|default %0d",r);
 #1 hidden=11;
 #1 $display("T|body %0d",r);
 #1 unrelated=19;
 #1 $display("T|unrelated %0d",r);
 $finish;end
endmodule
