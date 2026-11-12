// IEEE 1800-2023 §§6.8,10.8 convert to the declared unsigned type; §§11.8.1,11.8.2 give bit patterns 111, fffb, 89, interpreted as 7,65531,137. §11.8.2: "Propagate the type and size of the expression".
// A signed initializer cannot make an unsigned declared package variable signed.
`timescale 1ns/1ps
package pq;
 bit [2:0] a=3'sb110^3'sb001;
 logic [15:0] f=~(+$countones(8'hC5));
 logic [7:0] p=4'sd3**2|8'sh80;
endpackage
module top;
 import pq::*;
 int wide;
 initial begin #1;wide=pq::a;#1;
 $display("T|package %0d %0d %0d %0d %0d %0d",pq::a,pq::a>2,wide,pq::f,pq::p,a);$finish;end
endmodule
