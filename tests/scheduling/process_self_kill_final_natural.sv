// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
module top;
 process p; int x;
 initial begin p=process::self(); x=1; p.kill(); x=2; end
 final begin $display("FINAL natural x=%0d",x); end
endmodule
