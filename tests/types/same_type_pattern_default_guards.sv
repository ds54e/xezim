// IEEE 1800-2023 §10.9.2: nonmatching defaults recurse; explicit keys win.
`timescale 1ns/1ps
typedef struct packed {logic [3:0] a,b;} P;
typedef struct {int tag; P pk;} S;
module top;
  parameter int K=2;
  P p;
  S scalar,sized,param_expr,zero,ones,type_key,nested_pattern;
  logic x;
  assign scalar='{tag:7,default:x};
  assign sized='{tag:7,default:8'h12};
  assign param_expr='{tag:7,default:K+1};
  assign zero='{tag:7,default:'0};
  assign ones='{tag:7,default:'1};
  assign type_key='{int:9,P:8'h34,default:p};
  assign nested_pattern='{tag:7,pk:'{default:4'h5}};
  initial begin
    p=8'h12;
    x=1;
    #1;
    $display("T|scalar %0d %h %h",scalar.tag,scalar.pk.a,scalar.pk.b);
    $display("T|sized %0d %h %h",sized.tag,sized.pk.a,sized.pk.b);
    $display("T|param_expr %0d %h %h",param_expr.tag,param_expr.pk.a,param_expr.pk.b);
    $display("T|zero %0d %h %h",zero.tag,zero.pk.a,zero.pk.b);
    $display("T|ones %0d %h %h",ones.tag,ones.pk.a,ones.pk.b);
    $display("T|type_key %0d %h %h",type_key.tag,type_key.pk.a,type_key.pk.b);
    $display("T|nested_pattern %0d %h %h",nested_pattern.tag,nested_pattern.pk.a,nested_pattern.pk.b);
    $finish;
  end
endmodule
