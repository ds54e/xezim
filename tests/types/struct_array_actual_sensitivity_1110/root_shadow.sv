// §23.9: an instance-local block called top shadows the top module name;
// §23.6: $root bypasses that shadow, including inside a named actual.
`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input S x[2]); return int'($time); endfunction
module child;
 if(1) begin:top S a[2]; end
 int local_name, rooted, named_root;
 assign local_name=f(top.a);
 assign rooted=f($root.top.a);
 assign named_root=f(.x($root.top.a));
endmodule
module top;
 S a[2]; child c();
 initial begin
 #1 a[0].v=7;
 #1 $display("T|root %0d %0d %0d",c.local_name,c.rooted,c.named_root);
 #1 c.top.a[0].v=11;
 #1 $display("T|local %0d %0d %0d",c.local_name,c.rooted,c.named_root);
 $finish;end
endmodule
