`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input S x); return int'($time); endfunction
module top;
S a;
int r;
assign r=f(.x(a));
initial begin
#1 a.v=7;
#1 $display("T|value %0d",r);
$finish;
end
endmodule
