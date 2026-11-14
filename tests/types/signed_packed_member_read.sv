`timescale 1ns/1ps
// IEEE 1800-2023 §§6.11.3, 7.2.1, 11.8.1, 11.8.3.
module top;
  typedef struct packed { int f; int unsigned u; shortint n; byte b; } S;
  typedef struct packed signed { logic [31:0] u; logic signed [7:0] n; } U;
  typedef logic signed [7:0] signed_byte;
  typedef enum int { NEG = -1, POS = 1 } E;
  typedef struct packed { signed_byte a; E e; logic [3:0] pad; } T;
  S s;
  S arr[0:1];
  U us;
  T t;
  longint q, qp, qu, qn, qb, su, sn, ta, te, mixed_direct, conditional_direct;
  longint part, fullpart, bitval, catval;
  longint proc, comb_member;
  assign q = s.f;
  assign qp = arr[0].f;
  assign qu = s.u;
  assign mixed_direct = arr[0].f + arr[0].u;
  assign conditional_direct = 1'b1 ? arr[0].f : arr[0].u;
  assign qn = s.n;
  assign qb = s.b;
  assign su = us.u;
  assign sn = us.n;
  assign ta = t.a;
  assign te = t.e;
  assign part = s.f[15:0];
  assign fullpart = s.f[31:0];
  assign bitval = s.f[31];
  assign catval = {s.f};
  always_comb begin proc = s.f; comb_member = arr[0].f; end
  task check(input string label_, input logic [63:0] got, expected);
    $display("%s %s got=%h expected=%h", got === expected ? "PASS" : "FAIL", label_, got, expected);
  endtask
  initial begin
    arr[0].f = -1; arr[0].u = '1;
    s.f = -1; s.u = '1; s.n = -2; s.b = -3;
    us.u = '1; us.n = -4; t.a = -5; t.e = NEG; t.pad = 0;
    #1;
    check("int_dotted", q, 64'hffffffffffffffff);
    check("int_member_access", qp, 64'hffffffffffffffff);
    check("mixed_direct", mixed_direct, 64'h00000001fffffffe);
    check("conditional_direct", conditional_direct, 64'h00000000ffffffff);
    check("unsigned_int", qu, 64'h00000000ffffffff);
    check("shortint", qn, 64'hfffffffffffffffe);
    check("byte", qb, 64'hfffffffffffffffd);
    check("signed_container_unsigned_field", su, 64'h00000000ffffffff);
    check("signed_container_signed_field", sn, 64'hfffffffffffffffc);
    check("typedef_field", ta, 64'hfffffffffffffffb);
    check("enum_field", te, 64'hffffffffffffffff);
    check("part_select", part, 64'hffff);
    check("full_part_select", fullpart, 64'hffffffff);
    check("bit_select", bitval, 64'h1);
    check("concatenation", catval, 64'hffffffff);
    check("always_comb_dotted", proc, 64'hffffffffffffffff);
    check("always_comb_member", comb_member, 64'hffffffffffffffff);
    s.f = 123;
    #1; check("positive_member", q, 64'd123);
    s.f = 32'sh80000000;
    #1; check("minimum_int", q, 64'hffffffff80000000);
    $finish;
  end
endmodule
