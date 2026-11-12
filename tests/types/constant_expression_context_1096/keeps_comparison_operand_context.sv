// IEEE 1800-2023 §11.8.2 comparison exception: operands "shall affect each other as if they were context-determined operands"; Table 11-21 makes 3+3+7=13 at 4 bits, so equality to 5 is false (and inequalities true).
// Comparison operands need joint width despite a one-bit result; dependent dimensions and generate selection must stay right.
`timescale 1ns/1ps
module top;
 localparam EQ=((2'b11+2'b11)+3'b111)==4'd5;
 localparam NE=((2'b11+2'b11)+3'b111)!=4'd5;
 localparam CE=((2'b11+2'b11)+3'b111)===4'd5;
 localparam CN=((2'b11+2'b11)+3'b111)!==4'd5;
 localparam WE=((2'b11+2'b11)+3'b111)==?4'd5;
 localparam WN=((2'b11+2'b11)+3'b111)!=?4'd5;
 localparam bit T=((2'b11+2'b11)+3'b111)==4'd5;
 logic v=((2'b11+2'b11)+3'b111)==4'd5;
 localparam D=EQ+1;logic [D-1:0] vec;
 if(EQ)begin:g initial #1 $display("T|branch wrong");end
 else begin:g initial #1 $display("T|branch right");end
 initial begin #2;$display("T|compare %b%b%b%b%b%b %b %b %0d %0d",EQ,NE,CE,CN,WE,WN,T,v,D,$bits(vec));$finish;end
endmodule
