// IEEE 1800-2023 §§10.5, 10.8, 10.9.2: sample after assignment settling.
`timescale 1ns/1ps
typedef struct packed {logic [3:0] a,b;} P;
typedef struct {int tag; P pk;} S;
module top;
  parameter P PP=8'h12;
  localparam P LP=8'h34;
  parameter S PS='{tag:7,default:PP};
  localparam S LS='{tag:9,default:LP};
  S init_s='{tag:5,default:PP};
  P p;
  S proc_s,comb_s,ret_s;
  int result;
  function automatic int arg(input S s);
    return s.pk;
  endfunction
  function automatic S ret(input P x);
    return '{tag:11,default:x};
  endfunction
  assign comb_s='{tag:7,default:p};
  initial begin
    p=8'h56;
    #1;
    proc_s='{tag:3,default:p};
    result=arg('{tag:0,default:p});
    ret_s=ret(p);
    $display("T|proc %0d %h %h",proc_s.tag,proc_s.pk.a,proc_s.pk.b);
    $display("T|comb %0d %h %h",comb_s.tag,comb_s.pk.a,comb_s.pk.b);
    $display("T|initializer %0d %h %h",init_s.tag,init_s.pk.a,init_s.pk.b);
    $display("T|parameter %0d %h %h",PS.tag,PS.pk.a,PS.pk.b);
    $display("T|localparam %0d %h %h",LS.tag,LS.pk.a,LS.pk.b);
    $display("T|argument %h",result[7:0]);
    $display("T|return %0d %h %h",ret_s.tag,ret_s.pk.a,ret_s.pk.b);
    #2;
    $finish;
  end
endmodule
