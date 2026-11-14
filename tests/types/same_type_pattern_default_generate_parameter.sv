// IEEE 1800-2023 §6.22.1(b,d), §6.6.7 and §10.9.2.
`timescale 1ns/1ps
// §6.20.3 / §27: a generate-local type parameter hides the unit typedef.
typedef struct packed {logic [3:0] a,b;} P;   // $unit::P
typedef struct {int tag; P pk;} S;            // S.pk is $unit::P
typedef struct packed {logic [3:0] c,d;} Q;
module top;
  S s1, s2;
  if (1) begin : g
    localparam type P = Q;                    // g.P is Q
    typedef P PT;
    PT q;
    P  q2;
    assign s1 = '{tag:7,default:q};           // Q into $unit::P member: 66
    assign s2 = '{tag:7,default:q2};          // 66
  end
  initial begin
    g.q=8'h56; g.q2=8'h56; #1;
    $display("T|gen_lptype_alias %0d %h", s1.tag, s1.pk);
    $display("T|gen_lptype_direct %0d %h", s2.tag, s2.pk);
    $finish;
  end
endmodule
