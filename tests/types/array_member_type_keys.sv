`timescale 1ns/1ps
// IEEE 1800-2023 §10.9.1, §10.9.2: explicit keys, matching types, default.
module top;
  typedef integer word_t;
  typedef struct {integer p; byte q;} pair_t;
  typedef struct {
    integer a[3]; int b[2]; byte c[2]; word_t d[2];
    logic [7:0] e[2]; logic [1:0][3:0] packed_a[2];
    integer m[2][2]; pair_t s[2];
  } S;
  function automatic S f(input S drivers[]);
    S result;
    result.a[0] = drivers[0].a[0];
    result.a[1] = drivers[0].a[1];
    result.a[2] = drivers[0].a[2];
    result.b[0] = drivers[0].b[0];
    result.b[1] = drivers[0].b[1];
    result.c[0] = drivers[0].c[0];
    result.c[1] = drivers[0].c[1];
    result.d[0] = drivers[0].d[0];
    result.d[1] = drivers[0].d[1];
    result.e[0] = drivers[0].e[0];
    result.e[1] = drivers[0].e[1];
    result.packed_a[0] = drivers[0].packed_a[0];
    result.packed_a[1] = drivers[0].packed_a[1];
    result.m[0][0] = drivers[0].m[0][0];
    result.m[0][1] = drivers[0].m[0][1];
    result.m[1][0] = drivers[0].m[1][0];
    result.m[1][1] = drivers[0].m[1][1];
    result.s[0].p = drivers[0].s[0].p;
    result.s[0].q = drivers[0].s[0].q;
    result.s[1].p = drivers[0].s[1].p;
    result.s[1].q = drivers[0].s[1].q;
    return result;
  endfunction
  nettype S N with f;
  nettype S U;
  N n;
  S v, n_var;
  U u;
  integer x;
  assign n = '{a:'{integer:x, 1:x+1, default:99},
               b:'{integer:98, int:x+2, default:99},
               c:'{byte:x+3, default:99},
               d:'{integer:x+4, default:99},
               e:'{default:x+5},
               packed_a:'{default:8'haa},
               m:'{'{integer:x+6, default:99}, '{0:x+7, integer:x+8, default:99}},
               s:'{'{integer:x+9, byte:3}, '{p:x+10, q:4}}};
  assign v = '{a:'{integer:x, 1:x+1, default:99}, default:0};
  assign u = '{a:'{integer:x, 1:x+1, default:99}, default:0};
  initial begin
    #1 x = 7;
    n_var = '{a:'{integer:x, default:99}, default:0};
    #1;
    $display("T|integer %0d %0d %0d int %0d %0d byte %0d %0d", n.a[0],n.a[1],n.a[2],n.b[0],n.b[1],n.c[0],n.c[1]);
    $display("T|typedef %0d %0d vector %0d %0d packed %h %h",n.d[0],n.d[1],n.e[0],n.e[1],n.packed_a[0],n.packed_a[1]);
    $display("T|nested %0d %0d %0d %0d struct %0d %0d %0d %0d",n.m[0][0],n.m[0][1],n.m[1][0],n.m[1][1],n.s[0].p,n.s[0].q,n.s[1].p,n.s[1].q);
    $display("T|plain %0d %0d %0d unresolved %0d %0d %0d procedural %0d %0d %0d",v.a[0],v.a[1],v.a[2],u.a[0],u.a[1],u.a[2],n_var.a[0],n_var.a[1],n_var.a[2]);
    #1 x = 11;
    #1 $display("T|update %0d %0d %0d %0d",n.a[0],n.a[1],n.d[0],n.e[0]);
    $finish;
  end
endmodule
