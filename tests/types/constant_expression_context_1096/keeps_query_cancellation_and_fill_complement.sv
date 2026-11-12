// IEEE 1800-2023 §20.7 $size of the 8-bit vector is 8; §§11.6,11.8 size denominator to 64 bits: (9-8)%(15+3)=1. §6.20.2 unsized untyped parameter range is "of at least 31" MSB; all-ones complement is zero at every permitted width.
// Keep a query-dependent correct result and numeric fill-parameter complement; omit main-wrong query leaf and implementation-dependent width.
`timescale 1ns/1ps
module child;
 localparam logic [7:0] TP=8'hC5;localparam logic signed [7:0] TS=-8'sd3;localparam UP=2'b11;
 parameter A=(64'h9-$size(TP))%(TS[7:4]+UP);
 localparam FILL='1;localparam P=(~FILL)+4'd0;
 initial #1 $display("T|fallback %0d %0d",A,P);
endmodule
module top;child d();initial #2 $finish;endmodule
