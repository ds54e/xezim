`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int fi(input S x[2]); return x[1].v; endfunction
task automatic ti(input S x[2]); $display("T|task_i %0d",x[1].v); endtask
function automatic int fc(const ref S x[2]); return x[1].v; endfunction
task automatic tc(const ref S x[2]); $display("T|task_c %0d",x[1].v); endtask
function automatic int fr(ref S x[2]); return x[1].v; endfunction
task automatic tr(ref S x[2]); $display("T|task_r %0d",x[1].v); endtask
task automatic put(ref S x[2], input int v); x[1].v=v; endtask
module top; S a[2]; if(1) begin:h S a[2]; end
initial begin
#1 a[1].v=21; h.a[1].v=23;
#1
$display("T|function_i_pos %0d",fi(a)); ti(a);
$display("T|function_i_named %0d",fi(.x(a))); ti(.x(a));
$display("T|function_i_root %0d",fi($root.top.a)); ti($root.top.a);
$display("T|function_i_top %0d",fi(top.a)); ti(top.a);
$display("T|function_i_block %0d",fi(h.a)); ti(h.a);
$display("T|function_c_pos %0d",fc(a)); tc(a);
$display("T|function_c_named %0d",fc(.x(a))); tc(.x(a));
$display("T|function_c_root %0d",fc($root.top.a)); tc($root.top.a);
$display("T|function_c_top %0d",fc(top.a)); tc(top.a);
$display("T|function_c_block %0d",fc(h.a)); tc(h.a);
$display("T|function_r_pos %0d",fr(a)); tr(a);
$display("T|function_r_named %0d",fr(.x(a))); tr(.x(a));
$display("T|function_r_root %0d",fr($root.top.a)); tr($root.top.a);
$display("T|function_r_top %0d",fr(top.a)); tr(top.a);
$display("T|function_r_block %0d",fr(h.a)); tr(h.a);
put(a,31);
$display("T|write_pos %0d %0d",a[1].v,h.a[1].v);
put(.x(a),.v(32));
$display("T|write_named %0d %0d",a[1].v,h.a[1].v);
put($root.top.a,33);
$display("T|write_root %0d %0d",a[1].v,h.a[1].v);
put(top.a,34);
$display("T|write_top %0d %0d",a[1].v,h.a[1].v);
put(h.a,35);
$display("T|write_block %0d %0d",a[1].v,h.a[1].v);
$finish; end endmodule
