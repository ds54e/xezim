// IEEE 1800-2023 §11.4.11: if both conditional arms have the same value, the merged result is that value; adding zero preserves zero (§11.4.3). §11.8.2: "Propagate the type and size of the expression".
// Identical unknown-condition arms stay zero under a declined arithmetic chain. This checks values, not asymptotic cost.
`timescale 1ns/1ps
module top;
 localparam P=((((1'bx ? 8'd0 : 8'd0)+8'd0)+8'd0)+8'd0)+8'd0;
 initial begin #1;$display("T|declined %0d",P);$finish;end
endmodule
