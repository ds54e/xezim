`timescale 1ns/1ps
// IEEE 1800-2023 §6.24.1, §6.12.1: integral casts round, ties away
// from zero; §6.11 defines target widths and signs. §20.5 keeps bit
// reinterpretation distinct. Samples follow stimulus by #1 (§4.7).
module cast_sink(input wire [63:0] v); endmodule
module cast_parameter #(parameter longint P=0) (output wire [63:0] v);
  assign v=P;
endmodule
module top;
  typedef longint signed64_t;
  typedef logic [63:0] vector64_t;
  real r;
  shortreal sr;
  wire [63:0] r0 = longint'(r);
  wire [63:0] r1 = longint unsigned'(r);
  wire [63:0] r2 = signed64_t'(r);
  wire [63:0] r3 = vector64_t'(r);
  wire [31:0] r4 = int'(r);
  wire [15:0] r5 = shortint'(r);
  wire [7:0] r6 = byte'(r);
  wire [31:0] r7 = integer'(r);
  wire [63:0] r8 = time'(r);
  wire [63:0] sr0 = longint'(sr);
  wire [63:0] sr1 = longint unsigned'(sr);
  wire [63:0] sr2 = signed64_t'(sr);
  wire [63:0] sr3 = vector64_t'(sr);
  wire [31:0] sr4 = int'(sr);
  wire [15:0] sr5 = shortint'(sr);
  wire [7:0] sr6 = byte'(sr);
  wire [31:0] sr7 = integer'(sr);
  wire [63:0] sr8 = time'(sr);
  wire [63:0] explicit_assign;
  assign explicit_assign=longint'(r);
  logic [63:0] variable_assign;
  assign variable_assign=longint'(r);
  logic [63:0] comb;
  always_comb comb=longint'(r);
  cast_sink port_cast(longint'(r));
  parameter real R=10000.0;
  localparam longint L=longint'(R*1.0e9);
  wire [63:0] constant_cast=longint'(R*1.0e9);
  wire [63:0] literal_cast=longint'(2.5);
  wire [63:0] parameter_cast;
  cast_parameter #(longint'(R*1.0e9)) override_cast(parameter_cast);
  wire [63:0] bits=$realtobits(r);
  wire [31:0] trunc=$rtoi(r);
  longint proc;
  initial begin
    r=2.5; sr=-2.5; proc=longint'(r);
    #1;
    $display("T|r %h %h %h %h %h %h %h %h %h",r0,r1,r2,r3,r4,r5,r6,r7,r8);
    $display("T|sr %h %h %h %h %h %h %h %h %h",sr0,sr1,sr2,sr3,sr4,sr5,sr6,sr7,sr8);
    $display("T|sites %h %h %h %h %h",explicit_assign,variable_assign,comb,port_cast.v,proc);
    $display("T|constant %h %h %h %h",constant_cast,literal_cast,parameter_cast,L);
    $display("T|bits %h %h",bits,trunc);
    r=-2.5; sr=2.5; proc=longint'(r);
    #1;
    $display("T|r %h %h %h %h %h %h %h %h %h",r0,r1,r2,r3,r4,r5,r6,r7,r8);
    $display("T|sr %h %h %h %h %h %h %h %h %h",sr0,sr1,sr2,sr3,sr4,sr5,sr6,sr7,sr8);
    $display("T|sites %h %h %h %h %h",explicit_assign,variable_assign,comb,port_cast.v,proc);
    $display("T|bits %h %h",bits,trunc);
    $finish;
  end
endmodule
