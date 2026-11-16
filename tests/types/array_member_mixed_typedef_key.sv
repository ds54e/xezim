`timescale 1ns/1ps
// §10.9.1, §6.22.1: word_t matches integer; the last type value wins.
module top;
  typedef integer word_t;
  typedef struct {integer a[2];} S;
  S v;
  initial begin
    v = '{a:'{integer:1, word_t:99, default:99}};
    #1 $display("T|mixed typedef %0d %0d", v.a[0], v.a[1]);
    $finish;
  end
endmodule
