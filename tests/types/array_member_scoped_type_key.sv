`timescale 1ns/1ps
// IEEE 1800-2023 10.9.1, 6.22.1 b): in top, PT is the package's int, which does not
// match the integer elements, so default: applies. Expected "99 99" for both lines.
package p; typedef int PT; endpackage
module other; typedef integer PT; PT unused; endmodule
module top;
  import p::*;
  typedef struct {integer a[2];} S;
  function automatic S f(input S d[]);
    S s; s.a[0]=d[0].a[0]; s.a[1]=d[0].a[1]; return s;
  endfunction
  nettype S N with f;
  N n; S v; integer x;
  other o();
  assign n = '{a:'{PT:x, default:99}};
  initial begin
    #1 x = 7;
    v = '{a:'{PT:x, default:99}};
    #1 $display("T|resolved net %0d %0d", n.a[0], n.a[1]);
    $display("T|variable %0d %0d", v.a[0], v.a[1]);
    $finish;
  end
endmodule
