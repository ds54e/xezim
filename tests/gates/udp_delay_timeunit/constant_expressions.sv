// §6.20 / §13.4 / §29.8 / §3.14.1–§3.14.2: parameters and replication
// retain numeric values; nonconstant calls/selects keep existing fallbacks.
`timescale 1ns/1ps
package timing;
  parameter int D = 4;
  parameter real R = 4.0;
endpackage
primitive copy_udp(q, a);
  output q; input a; table 0:0; 1:1; endtable
endprimitive
module top;
  reg a;
  reg index = 1;
  localparam int delays[2] = '{4000, 4};
  function automatic int selected_delay(int unused); return index ? 4 : 4000; endfunction
  wire [4:0] q;
  wire g;
  copy_udp #(timing::D) ui(q[0], a);
  copy_udp #(timing::R) ur(q[1], a);
  copy_udp #(selected_delay(2)) uf(q[2], a);
  copy_udp #({2{2'b01}}) uc(q[3], a);
  // Nonconstant index: keep main's existing fallback (4000 ticks = 4ns),
  // which coincides with delays[index]=4. The gate is a 4ns control.
  copy_udp #(delays[index]) uv(q[4], a);
  buf #4 gg(g, a);
  initial begin
    a = 0; #10 a = 1;
    #1 $display("U|constants-before %b %b", q, g);
    #5 $display("U|constants-after %b %b", q, g);
    $finish;
  end
endmodule
