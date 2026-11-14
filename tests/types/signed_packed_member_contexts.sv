`timescale 1ns/1ps
// IEEE 1800-2023 §§7.2.1, 11.6, 11.8.1–11.8.4, 13.5.1.
module top;
  typedef struct packed { logic signed [7:0] f; logic [7:0] u; } S;
  S s;
  longint add_s, add_u, and_s, and_u, neg, asr, lsr, cond_s, cond_u;
  longint cast_s, cast_u, explicit_part;
  longint unsigned uq;
  logic less, equal;
  logic [3:0] narrow_value;
  logic [127:0] wide;
  longint procedural, nonblocking, formal;
  longint mixed_members, mixed_member_cond, mixed_member_and;
  logic mixed_compare;
  assign mixed_members = s.f + s.u;
  assign mixed_member_cond = 1'b1 ? s.f : s.u;
  assign mixed_member_and = s.f & s.u;
  assign mixed_compare = s.f < s.u;
  assign add_s = s.f + 64'sd2;
  assign add_u = s.f + 64'd2;
  assign and_s = s.f & -1;
  assign and_u = s.f & 64'hffffffffffffffff;
  assign neg = -s.f;
  assign asr = s.f >>> 1;
  assign lsr = s.f >> 1;
  assign cond_s = 1'b1 ? s.f : 64'sd0;
  assign cond_u = 1'b1 ? s.f : 64'd0;
  assign cast_s = $signed(s.u);
  assign cast_u = $unsigned(s.f);
  assign explicit_part = s.f[7:0];
  assign uq = s.f;
  assign less = s.f < 0;
  assign equal = s.f == -2;
  assign narrow_value = s.f;
  assign wide = s.f;
  function automatic longint widen(input S arg);
    return arg.f;
  endfunction
  task check(input string label_, input logic [127:0] got, expected);
    $display("%s %s got=%h expected=%h", got === expected ? "PASS" : "FAIL", label_, got, expected);
  endtask
  initial begin
    s.f = -2; s.u = 8'hfe;
    #1;
    procedural = s.f; nonblocking <= s.f; formal = widen(s);
    #1;
    check("mixed_members", mixed_members, 128'd508);
    check("mixed_member_cond", mixed_member_cond, 128'hfe);
    check("mixed_member_and", mixed_member_and, 128'hfe);
    check("mixed_compare", mixed_compare, 128'd0);
    check("signed_add", add_s, 128'd0);
    check("unsigned_add", add_u, 128'd256);
    check("signed_bitwise", and_s, {128{1'b1}} - 1);
    check("unsigned_bitwise", and_u, 128'hfe);
    check("negate", neg, 128'd2);
    check("arithmetic_shift", asr, {128{1'b1}});
    check("logical_shift", lsr, 128'h7fffffffffffffff);
    check("signed_conditional", cond_s, {128{1'b1}} - 1);
    check("unsigned_conditional", cond_u, 128'hfe);
    check("signed_cast", cast_s, {128{1'b1}} - 1);
    check("unsigned_cast", cast_u, 128'hfe);
    check("explicit_part", explicit_part, 128'hfe);
    check("unsigned_lhs", {64'b0, uq}, 128'h0000000000000000fffffffffffffffe);
    check("signed_compare", less, 128'd1);
    check("signed_equal", equal, 128'd1);
    check("truncate", narrow_value, 128'he);
    check("wide_128", wide, {128{1'b1}} - 1);
    check("procedural", procedural, {128{1'b1}} - 1);
    check("nonblocking", nonblocking, {128{1'b1}} - 1);
    check("formal_control", formal, {128{1'b1}} - 1);
    $finish;
  end
endmodule
