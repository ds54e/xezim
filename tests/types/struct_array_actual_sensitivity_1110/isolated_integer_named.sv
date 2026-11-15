`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input int x[2]); return int'($time); endfunction
module top;
int a[2];
int r;
assign r=f(.x(a));
initial begin
#1 a[1]=7;
#1 $display("T|value %0d",r);
$finish;
end
endmodule
