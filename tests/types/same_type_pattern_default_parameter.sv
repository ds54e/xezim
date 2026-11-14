// IEEE 1800-2023 §6.22.1(b,d), §6.6.7 and §10.9.2.
`timescale 1ns/1ps
// A type parameter of the top module hides a $unit typedef of the same name.
typedef struct packed {logic [3:0] a,b;} P;   // $unit::P
typedef struct {int tag; P pk;} S;            // S.pk is $unit::P
typedef struct packed {logic [3:0] c,d;} Q;
module top #(parameter type P = Q);           // top.P is Q, hides $unit::P
  typedef P PT;                               // alias of the type parameter: Q
  PT q;
  P  q2;
  logic [7:0] v;
  S s, s2, sc;
  assign s  = '{tag:7,default:q};             // Q value into $unit::P member: descends
  assign s2 = '{tag:7,default:q2};
  assign sc = '{tag:7,default:v};             // control
  initial begin
    q=8'h56; q2=8'h56; v=8'h56; #1;
    $display("T|typeparam_alias %0d %h", s.tag, s.pk);
    $display("T|typeparam_direct %0d %h", s2.tag, s2.pk);
    $display("T|typeparam_ctrl %0d %h", sc.tag, sc.pk);
    $finish;
  end
endmodule
