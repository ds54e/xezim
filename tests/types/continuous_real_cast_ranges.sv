`timescale 1ns/1ps
// §6.24.1 / §6.12.1: exact values, rounding and target sign/width.
// §6.11: unsigned longint and time can represent a value above 2**63.
module top;
  typedef longint unsigned u64_t;
  real r;
  wire [63:0] s=longint'(r), u=u64_t'(r), t=time'(r);
  wire [63:0] literal_large=longint'(9007199254740994.0);
  wire [63:0] literal_unsigned=u64_t'(9223372036854777856.0);
  initial begin
    r=0.5;
    #1 $display("T|round %h %h %h",s,u,t);
    r=-0.5;
    #1 $display("T|round %h %h %h",s,u,t);
    r=2.4;
    #1 $display("T|round %h %h %h",s,u,t);
    r=-2.6;
    #1 $display("T|round %h %h %h",s,u,t);
    r=9007199254740994.0;
    #1 $display("T|large %h %h %h %h",s,u,t,literal_large);
    r=-9007199254740994.0;
    #1 $display("T|large %h %h %h",s,u,t);
    r=9223372036854777856.0;
    #1 $display("T|unsigned %h %h %h",u,t,literal_unsigned);
    $finish;
  end
endmodule
