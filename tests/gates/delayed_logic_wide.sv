// IEEE 1800-2023 §28.3.5/§28.3.6 and §28.5: preserve array bit
// distribution and map only z bits to x, including scalar fill inputs.
`timescale 1ns/1ps
module top;
  logic [64:0] i;
  wire [64:0] delayed, zero_delay;
  wire [3:0] fill;
  buf #(2,4) b[64:0](delayed,i);
  buf #(0,0) z[64:0](zero_delay,i);
  buf #(2,4) f[3:0](fill,'z);
  initial begin
    #1 i=0;
    #9 i=65'b1z0000000000000000000000000000000000000000000000000000000000001xz;
    #7;
    if (delayed === 65'b1x0000000000000000000000000000000000000000000000000000000000001xx) $display("PASS wide delayed"); else $display("FAIL wide delayed=%b",delayed);
    if (zero_delay === 65'b1x0000000000000000000000000000000000000000000000000000000000001xx) $display("PASS wide zero"); else $display("FAIL wide zero=%b",zero_delay);
    if (fill === 4'bxxxx) $display("PASS fill"); else $display("FAIL fill=%b",fill);
  end
endmodule
