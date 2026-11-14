// IEEE 1800-2023 §6.22.1(h): a package type matches through either spelling.
`timescale 1ns/1ps
package pkg;
  typedef struct packed {logic [3:0] a,b;} P;
  typedef struct {int tag; P pk;} S;
endpackage
module child;
  pkg::P p;
  pkg::S s;
  assign s = '{tag:7,default:p};
  initial p = 8'h34;
endmodule
module top;
  import pkg::P;
  P p;
  pkg::P q;
  pkg::S s, t;
  // Registers the package aliases a second time; only top values are sampled.
  child u();
  assign s = '{tag:7,default:p};
  assign t = '{tag:9,default:q};
  initial begin
    p = 8'h12;
    q = 8'h56;
    #1;
    $display("T|package_alias %0d %h %0d %h", s.tag, s.pk, t.tag, t.pk);
    $finish;
  end
endmodule
