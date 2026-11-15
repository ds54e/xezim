`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int stamp(input S x); return int'($time); endfunction
module child;
 if (1) begin : h S a; end
 int r;
 assign r=stamp(h.a);
endmodule
module top;
 S a;
 if (1) begin : h S a; end
 child c(); child d();
 int positional, named_arg, rooted, top_name, both;
 assign positional=stamp(a);
 assign named_arg=stamp(.x(a));
 assign rooted=stamp($root.top.a);
 assign top_name=stamp(top.a);
 assign both=stamp(.x(a))+stamp($root.top.c.h.a);
 initial begin
 #1 a.v=7;
 #1 $display("T|0 %0d %0d %0d %0d",positional,named_arg,rooted,top_name);
 #1 $root.top.a.v=9;
 #1 $display("T|1 %0d %0d %0d %0d",positional,named_arg,rooted,top_name);
 #1 top.a.v=11;
 #1 $display("T|2 %0d %0d %0d %0d",positional,named_arg,rooted,top_name);
 #1 c.h.a.v=13;
 #1 $display("T|3 %0d %0d %0d %0d",positional,named_arg,rooted,top_name);
 #1 h.a.v=17;
 #1 $display("T|4 %0d %0d %0d %0d",positional,named_arg,rooted,top_name);
 #1 d.h.a.v=19;
 #1 $display("T|5 %0d %0d %0d %0d",positional,named_arg,rooted,top_name);
 $finish;
 end
endmodule
