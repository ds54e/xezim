// IEEE 1800-2023 §6.16: "A string variable shall not contain the special character" \0; §§6.20.2,10.8 convert the selected de arm to string; §21.2.1.7 formats text.
// Ordered/named/defparam string overrides must convert away integral leading zero padding.
`timescale 1ns/1ps
module sub #(parameter string NAME="dflt")();
 initial #1 $display("T|text [%s] [%s] %0d",NAME,$sformatf("%s.txt",NAME),NAME.len());
endmodule
module top;
 localparam int SEL=0;
 sub #(SEL ? "abc" : "de") ordered();
 sub #(.NAME(1 ? "de" : "abc")) named();
 sub dp();defparam dp.NAME=SEL ? "abc" : "de";
 initial #2 $finish;
endmodule
