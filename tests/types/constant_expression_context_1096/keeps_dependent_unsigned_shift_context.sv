// IEEE 1800-2023 §11.8.1: "If any operand is unsigned, the result is unsigned"; §§10.8,11.8.2 zero-extend 4-bit PN=1010 to 32 bits before >>>3, giving 1; OR 1 remains 1.
// A corrected signed producer still needs the unsigned context propagated through a shift in a constant function.
`timescale 1ns/1ps
module top;
 localparam PN=1 ? (3'sb011*3'sb110) : 4'sb0000;
 function automatic int f();return (PN>>>32'sd3)|8'd1;endfunction
 localparam int F=f();
 initial begin #1;$display("T|shift %0d %0d",F,f());$finish;end
endmodule
