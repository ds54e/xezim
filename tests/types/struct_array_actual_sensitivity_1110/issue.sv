`timescale 1ns/1ps
typedef struct { int v; } S;
function automatic int f(input S a[2]); return int'($time); endfunction
module child;
  if (1) begin : h S a[2]; end
  int r_block;
  assign r_block = f(h.a);
endmodule
module top;
  S a[2];
  int r_named, r_root, r_top;
  assign r_named = f(.a(a));
  assign r_root = f($root.top.a);
  assign r_top = f(top.a);
  child c();
  if (1) begin : h S a[2]; end
  initial begin
    #1 a[1].v = 7; c.h.a[1].v = 7;
    #1 begin
      if (r_named === 1) $display("PASS named"); else $display("FAIL named r=%0d expected=1", r_named);
      if (r_root === 1) $display("PASS root"); else $display("FAIL root r=%0d expected=1", r_root);
      if (r_top === 1) $display("PASS top"); else $display("FAIL top r=%0d expected=1", r_top);
      if (c.r_block === 1) $display("PASS block"); else $display("FAIL block r=%0d expected=1", c.r_block);
    end
    $finish;
  end
endmodule
