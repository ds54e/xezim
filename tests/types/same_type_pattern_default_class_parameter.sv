// IEEE 1800-2023 §6.20.3, §6.22.1(b,d), §10.9.2.
typedef struct packed {logic [3:0] a,b;} P;
typedef struct {int tag; P pk;} S;
typedef struct packed {logic [3:0] c,d;} Q;
class C #(parameter type P = Q); typedef P PT; endclass
module top;
  C#()::PT q; S s;
  assign s = '{tag:7, default:q};
  initial begin q=8'h56; #1; $display("T|class_parameter %0d %h", s.tag, s.pk); $finish; end
endmodule
