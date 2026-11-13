// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
`timescale 1ns/1ps
module top;
 bit clk; process p; int x, after_x;
 always @(posedge clk) begin p=process::self(); x++; p.kill(); after_x++; end
 initial begin #1; clk=1; #1; clk=0; end
 final $display("PASS edge final");
endmodule
