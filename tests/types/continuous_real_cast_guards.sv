`timescale 1ns/1ps
// §6.24.1: integral casts retain bits and take the target's signedness.
// §6.11.2: two-state targets clear X/Z. §20.5: $realtobits keeps real bits.
// §10.7: widening and narrowing an integral cast retain its numeric value.
module top;
  typedef longint i64_t;
  typedef logic [63:0] v64_t;
  typedef real real_t;
  real r;
  logic signed [63:0] x;
  wire [63:0] i=longint'(x), n=i64_t'(x), v=v64_t'(x), t=time'(x);
  wire [63:0] size=64'(x), fill=longint'('1), neg=longint'(-1);
  wire [63:0] wide=longint'(128'h123456789abcdef0fedcba9876543210);
  wire [63:0] nested=longint'(int'(r)), raw=longint'($realtobits(r));
  wire [63:0] br=$realtobits(real'(r));
  wire [63:0] bt=$realtobits(real_t'(r));
  wire [127:0] wide_real=longint'(r);
  wire [31:0] narrow_real=longint'(r);
  wire [63:0] shifted=longint'(x)>>4;
  initial begin
    r=2.5; x=64'hxz0123456789abcd;
    #1 $display("T|integral %h %h %h %h %h %h %h %h",i,n,v,t,size,fill,neg,wide);
    $display("T|real %h %h %h %h",nested,raw,br,bt);
    $display("T|context %h %h",wide_real,narrow_real);
    r=-2.5; x=-64'sd16;
    #1 $display("T|signed %h %h %h %h %h %h",i,n,v,t,size,shifted);
    $display("T|real %h %h %h %h",nested,raw,br,bt);
    $display("T|context %h %h",wide_real,narrow_real);
    r=0.0;
    #1 $display("T|context %h %h",wide_real,narrow_real);
    $finish;
  end
endmodule
