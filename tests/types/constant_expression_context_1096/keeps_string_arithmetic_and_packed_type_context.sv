// IEEE 1800-2023 §§6.16,6.24.1 string casts convert the self-determined 8-bit sum: (122+200)%256=66 (B), length 1; §§10.8,11.8.2 evaluate 9-10 at eight bits, giving ff in the packed member. §11.8.2: "Propagate the type and size of the expression".
// String casts have no integral context from the destination; a packed-structure typed parameter supplies its eight-bit assignment context.
`timescale 1ns/1ps
module top;
 typedef string text_t;localparam BYTE="z";
 string direct_text=string'(BYTE+8'd200);
 text_t aliased_text=string'(BYTE+8'd200);
 typedef struct packed {logic [7:0] v;} S;
 localparam S P=(4'd9-5'd10)+8'd0;
 initial begin #1;
 $display("T|typed-leaves %0d %0d %0d %0d %h",direct_text.len(),direct_text.getc(0),aliased_text.len(),aliased_text.getc(0),P.v);$finish;end
endmodule
