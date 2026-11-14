// IEEE 1800-2023 §6.22.1(b,d), §6.6.7 and §10.9.2.
`timescale 1ns/1ps
// §6.20.3 / §27: type parameters hide package and module typedefs.
package pk;
  typedef struct packed {logic [3:0] a,b;} P;   // pk::P
  typedef struct {int tag; P pk;} S;            // pk::S, member pk::P
endpackage
typedef struct packed {logic [3:0] c,d;} Q;
module top #(parameter type P = Q);             // top.P is Q
  import pk::S;
  typedef struct packed {logic [3:0] a,b;} L;   // top.L
  typedef struct {int tag; L pk;} SL;           // member top.L
  typedef P PT;
  PT q;
  S  s1;
  SL s2;
  assign s1 = '{tag:7,default:q};               // Q into pk::P member: 66
  if (1) begin : g
    localparam type L = Q;                      // g.L is Q, hides top.L
    typedef L LT;
    LT x;
    assign s2 = '{tag:7,default:x};             // Q into top.L member: 66
  end
  initial begin
    q=8'h56; g.x=8'h56; #1;
    $display("T|typeparam_hides_pkg_type %0d %h", s1.tag, s1.pk);
    $display("T|gen_lptype_hides_module_type %0d %h", s2.tag, s2.pk);
    $finish;
  end
endmodule
