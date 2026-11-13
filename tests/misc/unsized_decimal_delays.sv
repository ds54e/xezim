// IEEE 1800-2023 §9.4.1 and Annex A.6.5: a bare delay_value is an
// unsigned_number. Preserve its magnitude, also for a single number in
// parentheses. §9.4.5: blocking/nonblocking intra-assignment controls.
// §10.3.3 / §28.16: continuous, net and gate delays retain main's values.
`timescale 1ps/1ps
module top;
  logic a, b, c, d, nba;
  logic src = 0;
  wire cont, gate_out;
  assign #(64'd4294967296) cont = src;
  wire #(64'd10000000000) net_decl = src;
  wire #(64'd4294967296) net_delay;
  assign net_delay = src;
  buf #(64'd10000000000) g(gate_out, src);
  always @(cont) if (cont === 1'b1) $display("continuous %0t", $time);
  always @(net_decl) if (net_decl === 1'b1) $display("net_declaration %0t", $time);
  always @(net_delay) if (net_delay === 1'b1) $display("net %0t", $time);
  always @(gate_out) if (gate_out === 1'b1) $display("gate %0t", $time);

  initial #4294967296 $display("plain_small %0t", $time);
  initial #10000000000 $display("plain_large %0t", $time);
  initial #(4294967296) $display("paren_small %0t", $time);
  initial #((10000000000)) $display("paren_large %0t", $time);
  initial begin
    a = #4294967296 1;
    $display("intra_small %0t %0b", $time, a);
  end
  initial begin
    b = #10000000000 1;
    $display("intra_large %0t %0b", $time, b);
  end
  initial begin
    c = #(4294967296) 1;
    $display("intra_paren_small %0t %0b", $time, c);
  end
  initial begin
    d = #(10000000000) 1;
    $display("intra_paren_large %0t %0b", $time, d);
  end
  initial nba <= #10000000000 1;
  always @(nba) if (nba === 1'b1) $display("nba_large %0t", $time);
  initial begin
    #1 src = 1;
    // §4.7: observe away from the delayed net/gate updates.
    #(64'd10000000001);
    $display("structural %0b %0b %0b %0b", cont, net_decl, net_delay, gate_out);
    #(64'd9999999998);
    $display("watchdog %0t", $time);
    $finish;
  end
endmodule
