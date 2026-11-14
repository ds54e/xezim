// IEEE 1800-2023 §6.22.1(b,d), §6.6.7 and §10.9.2.
`timescale 1ns/1ps
// Type parameter whose value is an anonymous struct, used through an alias.
typedef struct packed {logic [3:0] a,b;} P;
typedef struct {int tag; P pk;} S;
module top #(parameter type P = struct packed {logic [3:0] c,d;});
  typedef P PT;
  PT q;
  logic [7:0] v;
  S s, sc;
  assign s  = '{tag:7,default:q};
  assign sc = '{tag:7,default:v};
  initial begin
    q=8'h56; v=8'h56; #1;
    $display("T|typeparam_anon_alias %0d %h", s.tag, s.pk);
    $display("T|typeparam_anon_ctrl %0d %h", sc.tag, sc.pk);
    $finish;
  end
endmodule
