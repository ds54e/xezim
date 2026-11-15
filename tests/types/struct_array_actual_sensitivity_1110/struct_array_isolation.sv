// §10.3.2, §13.5.1, §13.5.4, §23.9: each actual denotes one array.
`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input S a[2]); return int'($time); endfunction
module child;
  if (1) begin : h S a[2]; end
  int r;
  assign r = f(h.a);
endmodule
module top;
  S a[2];
  int positional, named_arg, rooted, top_name;
  assign positional = f(a);
  assign named_arg = f(.a(a));
  assign rooted = f($root.top.a);
  assign top_name = f(top.a);
  child c(); child d();
  if (1) begin : h S a[2]; end
  initial begin
    #1 a[1].v = 7;
    #1 $display("T|top %0d %0d %0d %0d %0d %0d", positional,named_arg,rooted,top_name,c.r,d.r);
    #1 c.h.a[1].v = 11;
    #1 $display("T|child %0d %0d %0d %0d %0d %0d", positional,named_arg,rooted,top_name,c.r,d.r);
    #1 h.a[1].v = 13;
    #1 $display("T|unrelated %0d %0d %0d %0d %0d %0d", positional,named_arg,rooted,top_name,c.r,d.r);
    #1 d.h.a[1].v = 17;
    #1 $display("T|sibling %0d %0d %0d %0d %0d %0d", positional,named_arg,rooted,top_name,c.r,d.r);
    $finish;
  end
endmodule
