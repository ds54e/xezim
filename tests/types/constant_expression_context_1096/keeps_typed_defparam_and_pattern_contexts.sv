// IEEE 1800-2023 §10.8 includes "A nondefault correspondence" in an assignment pattern and explicit typed parameter overrides; §23.10.1 sets the parameter via defparam; §11.8.2 yields -2/-6 at 16 or 32 bits.
// Typed defparam values and unpacked/packed pattern elements require destination widths.
`timescale 1ns/1ps
module child;parameter int P=0;parameter integer Q=0;parameter logic signed [15:0] S=0;endmodule
module top;
 child u();
 defparam u.P=4'sd3-(1 ? 4'sd5 : 4'd0);
 defparam u.Q=(1 ? -4'sd2 : 4'd0)*4'sd3;
 defparam u.S=4'sd3-(1 ? 4'sd5 : 4'd0);
 localparam int A[2]='{4'sd3-(1 ? 4'sd5 : 4'd0),(1 ? -4'sd2 : 4'd0)*4'sd3};
 typedef struct packed {int hi;int lo;} S;
 localparam S B='{hi:4'sd3-(1 ? 4'sd5 : 4'd0),lo:(1 ? -4'sd2 : 4'd0)*4'sd3};
 initial begin #1;$display("T|dest %0d %0d %0d %0d %0d %0d %0d",u.P,u.Q,u.S,A[0],A[1],$signed(B.hi),$signed(B.lo));$finish;end
endmodule
