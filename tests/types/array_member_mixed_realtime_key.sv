`timescale 1ns/1ps
// §10.9.1, §6.12: realtime matches real; the last type value wins.
module top;
  typedef struct {real r[2];} S;
  S v;
  initial begin
    v = '{r:'{real:1.5, realtime:9.0, default:9.0}};
    #1 $display("T|mixed realtime %0.1f %0.1f", v.r[0], v.r[1]);
    $finish;
  end
endmodule
