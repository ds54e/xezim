`timescale 1ns/1ps
// §10.9.1/§10.9.2: keys are independent of their textual ordering.
module top;
  typedef struct {integer a[3]; logic [7:0] b[2];} S;
  function automatic S f(input S drivers[]);
    S result;
    result.a[0]=drivers[0].a[0];
    result.a[1]=drivers[0].a[1];
    result.a[2]=drivers[0].a[2];
    result.b[0]=drivers[0].b[0];
    result.b[1]=drivers[0].b[1];
    return result;
  endfunction
  nettype S N with f;
  N unmatched, first_key, last_key, last_type, replicated, states;
  integer x;
  assign unmatched = '{a:'{int:x, byte:8, default:99}, b:'{integer:x, default:8}};
  assign first_key = '{a:'{1:x+1, integer:x, default:99}, b:'{default:x}};
  assign last_key = '{a:'{default:99, integer:x, 1:x+1}, b:'{default:x}};
  assign last_type = '{a:'{integer:2, integer:x, default:99}, b:'{default:8}};
  assign replicated = '{a:'{3{x}}, b:'{2{8'sh80}}};
  assign states = '{a:'{integer:32'shffff_ff80, default:99}, b:'{default:8'bxz10_0110}};
  initial begin
    #1 x=7;
    #1;
    $display("T|unmatched %0d %0d %0d %0d",unmatched.a[0],unmatched.a[1],unmatched.a[2],unmatched.b[0]);
    $display("T|indices %0d %0d %0d / %0d %0d %0d",first_key.a[0],first_key.a[1],first_key.a[2],last_key.a[0],last_key.a[1],last_key.a[2]);
    $display("T|last type %0d %0d %0d vectors %0d %0d",last_type.a[0],last_type.a[1],last_type.a[2],first_key.b[0],last_key.b[0]);
    $display("T|replication %0d %0d %0d %h %h",replicated.a[0],replicated.a[1],replicated.a[2],replicated.b[0],replicated.b[1]);
    $display("T|states %0d %0d %b",states.a[0],states.a[2],states.b[0]);
    $finish;
  end
endmodule
