// IEEE 1800-2023 §29.8 / §28.16 / §3.14.1–§3.14.2.
// Delay2, real/parameter/min:typ:max delays, and disjoint net drivers (§10.3).
// Samples are away from all transitions (§4.7).
`timescale 1ns/1ps
primitive copy_udp(q, a);
  output q; input a;
  table 0:0; 1:1; x:x; endtable
endprimitive
module ordinary #(parameter P = 4)(input a, output q);
  assign q = (P == 4) ? a : ~a;
endmodule
module top;
  localparam P = 4;
  reg a;
  wire [1:0] w;
  wire pair_q, real_q, param_q, mtm_q, gate_q, zero_q, bare_q, module_q;
  assign #6 w[0] = a;
  copy_udp #4 u(w[1], a);
  copy_udp #(4, 6) pair_u(pair_q, a);
  copy_udp #2.5 real_u(real_q, a);
  copy_udp #(P) param_u(param_q, a);
  copy_udp #((4:4:4)) mtm_u(mtm_q, a);
  copy_udp #0 zero_u(zero_q, a);
  copy_udp bare_u(bare_q, a);
  buf #4 g(gate_q, a);
  ordinary #(4) child(a, module_q);
  initial begin
    a = 0;
    #10 a = 1;
    #1 $display("U|early %b %b%b%b%b%b%b%b%b", w, pair_q, real_q, param_q, mtm_q, gate_q, zero_q, bare_q, module_q);
    #1.4 $display("U|real-before %b", real_q);
    #0.2 $display("U|real-after %b", real_q);
    #2.4 $display("U|rise %b %b%b%b%b%b", w, pair_q, real_q, param_q, mtm_q, gate_q);
    #2 $display("U|assign %b", w);
    #3 a = 0;
    #1 $display("U|fall-before %b %b", w, pair_q);
    #3.5 $display("U|fall-pair %b %b", w, pair_q);
    #2 $display("U|fall-after %b %b", w, pair_q);
    #3.5 a = 1'bx;
    #1 $display("U|x-before %b", pair_q);
    #3.5 $display("U|x-after %b", pair_q);
    $finish;
  end
endmodule
