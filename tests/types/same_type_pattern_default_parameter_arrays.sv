// IEEE 1800-2023 §6.22.1(b,d), §6.6.7 and §10.9.2.
`timescale 1ns/1ps
// More forms of an unregistered name (type parameter) that hides a $unit typedef.
typedef struct packed {logic [3:0] a,b;} P;   // $unit::P
typedef P UP;                                 // alias of $unit::P
typedef struct {int tag; P pk;} S;            // S.pk is $unit::P
typedef struct packed {logic [3:0] c,d;} Q;
typedef logic [1:0][3:0] M;                   // $unit::M
typedef struct {int tag; M pk;} MS;
typedef P [1:0] PA;                           // $unit packed array of $unit::P
typedef struct {int tag; PA pk;} SPA;
module top #(parameter type P = Q, parameter type M = logic [0:1][3:0]);
  typedef P PT;                               // Q
  typedef struct {int tag; P pk;} L;          // L.pk is Q
  typedef M MT;                               // logic [0:1][3:0]
  typedef P [1:0] QA;                         // packed array of Q
  UP up;                                      // $unit::P
  MT mr;
  QA qa;
  L  l;
  MS ms;
  SPA spa;
  PT q;
  assign l   = '{tag:7,default:up};           // $unit::P into Q member: descends, 22
  assign ms  = '{tag:7,default:mr};           // reversed-range array into $unit::M: descends, 6 6
  assign spa = '{tag:7,default:qa};           // Q[1:0] into P[1:0]: descends
  initial begin
    up=8'h12; mr=8'h56; qa=16'h1234; q=8'h56; #1;
    $display("T|unit_alias_into_typeparam_member %0d %h", l.tag, l.pk);
    $display("T|typeparam_multidim %0d %h %h", ms.tag, ms.pk[1], ms.pk[0]);
    $display("T|typeparam_packed_array %0d %h", spa.tag, spa.pk);
    $finish;
  end
endmodule
