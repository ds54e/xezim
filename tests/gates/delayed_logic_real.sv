// IEEE 1800-2023 §6.12.1 real-to-integral conversion and §28.5.
// Preserve the existing real/shortreal input conversion, including rounding.
// Stimulus and samples avoid time-zero and transition races (§4.7/§6.8).
`timescale 1ns/1ps
module top;
  real r;
  shortreal sr;
  wire rb,sb;
  buf #(2,4) b(rb,r), s(sb,sr);
  initial begin
    #1 r=0.0; sr=0.0;
    #7;
    if ({rb,sb} === 2'b00) $display("PASS real zero"); else $display("FAIL real zero=%b",{rb,sb});
    #3 r=1.0; sr=1.0;
    #7;
    if ({rb,sb} === 2'b11) $display("PASS real one"); else $display("FAIL real one=%b",{rb,sb});
    #3 r=1.6; sr=1.6;
    #7;
    if ({rb,sb} === 2'b00) $display("PASS real round"); else $display("FAIL real round=%b",{rb,sb});
    #3 r=-1.0; sr=-1.0;
    #7;
    if ({rb,sb} === 2'b11) $display("PASS real negative"); else $display("FAIL real negative=%b",{rb,sb});
  end
endmodule
