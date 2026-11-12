// IEEE 1800-2023 §11.6 Table 11-21 self-determines shift counts/exponents and concatenation operands; §6.24.1 sizes casts (4-bit 3+3=6, concat=96). §11.8.2 treats the integral arm as self-determined before real conversion (3-bit 18 wraps to 2); §11.4.11 merges identical arms. §11.8.2: "Propagate the type and size of the expression".
// Preserve shift counts, exponents, cast/concatenation boundaries, real conversion and identical ambiguous arms.
`timescale 1ns/1ps
module top;
 localparam SHIFT=1<<(2'b11+2'b01);
 localparam POWER=3'd3**(2'b11+2'b01);
 localparam CONCAT={4'(2'b11+2'b11),4'b0};
 localparam logic [3:0] CAST=((2'b11+2'b11)+3'b111)+4'(4'b0);
 localparam R=1 ? (3'sd3*3'sd3*3'sd2) : (8'd2**1.0);
 localparam real RP=2.0**1;
 localparam SAME=1'bx ? 3'b101 : 3'b101;
 initial begin #1;$display("T|boundary %0d %0d %0d %0d %0.1f %0.1f %b",SHIFT,POWER,CONCAT,CAST,R,RP,SAME);$finish;end
endmodule
