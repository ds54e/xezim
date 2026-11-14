// IEEE 1800-2023 §6.22.1(b,d), §6.6.7 and §10.9.2.
`timescale 1ns/1ps
// A nettype whose name hides a $unit typedef.
typedef struct packed {logic [3:0] a,b;} P;   // $unit::P
typedef struct {int tag; P pk;} S;
typedef struct packed {logic [3:0] c,d;} Q;
module top;
  nettype Q P;                                // top.P is a nettype with data type Q
  P  n;                                       // a net of nettype P
  Q  q;
  logic [7:0] v;
  S s, sc;
  assign n = q;
  assign s  = '{tag:7,default:n};             // Q-typed net into $unit::P member: 66
  assign sc = '{tag:7,default:v};
  initial begin
    q=8'h56; v=8'h56; #1;
    $display("T|nettype_hides %0d %h", s.tag, s.pk);
    $display("T|nettype_ctrl %0d %h", sc.tag, sc.pk);
    $finish;
  end
endmodule
