// IEEE 1800-2023 §§6.22.1(d), 10.9.2: typedef identity includes scope.
`timescale 1ns/1ps
typedef struct packed {logic [3:0] a,b;} P;
typedef struct {int tag; P pk;} S;
typedef struct packed {logic [3:0] a,b;} R;
typedef struct {int tag; R pk;} SR;
module top;
  P early;
  typedef struct packed {logic [3:0] c,d;} P;
  typedef P Alias;
  typedef struct {int tag; Alias pk;} Local;
  typedef struct packed {logic [3:0] a,b;} R;
  Alias q;
  R r;
  S hidden;
  Local earlier_outer_into_local;
  SR identical;
  assign hidden = '{tag:7,default:q};
  assign earlier_outer_into_local = '{tag:7,default:early};
  assign identical = '{tag:7,default:r};
  initial begin
    early = 8'h12;
    q = 8'h56;
    r = 8'h12;
    #1;
    $display("T|hidden %0d %h", hidden.tag, hidden.pk);
    $display("T|earlier_outer_into_local %0d %h", earlier_outer_into_local.tag, earlier_outer_into_local.pk);
    $display("T|identical %0d %h", identical.tag, identical.pk);
    $finish;
  end
endmodule
