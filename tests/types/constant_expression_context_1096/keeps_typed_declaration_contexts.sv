// IEEE 1800-2023 §10.8 explicitly typed parameter assignments are assignment-like; §§11.8.1,11.8.2 propagate 32 unsigned context bits before subtraction/multiplication: 3-5=-2, -1, (-2)*3=-6. §11.8.2: "Propagate the type and size of the expression".
// Generated, call-substituted, function-local and class typed declarations must keep destination context.
`timescale 1ns/1ps
class C;localparam int K=4'sd3-(1 ? 4'sd5 : 4'd0);endclass
module top;
 function automatic logic signed [3:0] f4(input logic signed [3:0] x);return x;endfunction
 localparam int TC=4'sd3-(1 ? f4(4'sd5) : 4'd0);
 function automatic int f();localparam int FP=4'sd3-(1 ? 4'sd5 : 4'd0);return FP;endfunction
 localparam int FC=f();
 if(1)begin:g
 localparam int D0=4'sd3-(1 ? 4'sd5 : 4'd0);
 localparam integer D1=-(1 ? 1'sh1 : 8'h80);
 localparam int D2=(1 ? -4'sd2 : 4'd0)*4'sd3;
 initial #1 $display("T|generated %0d %0d %0d",D0,D1,D2);
 end
 initial begin #2;$display("T|typed %0d %0d %0d",TC,FC,C::K);$finish;end
endmodule
