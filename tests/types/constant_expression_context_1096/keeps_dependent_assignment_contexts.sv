// IEEE 1800-2023 §§10.8,11.8.2 supply 32 bits to multiplication/remainder: U=6, 6*15=90, 90%5=0; §23.10.1 gives defparam the same typed destination. §11.8.2: "Propagate the type and size of the expression".
// Correcting a producer parameter must not break a previously correct function/pattern/defparam consumer. U itself is deliberately not asserted.
`timescale 1ns/1ps
module child;parameter int P=0;endmodule
module top;
 localparam U=(2'b11+2'b11)+3'b0;
 function automatic int f();return (U*5'd15)%4'd5;endfunction
 localparam int F=f();localparam int A[1]='{(U*5'd15)%4'd5};
 child d();defparam d.P=(U*5'd15)%4'd5;
 child #(.P((U*5'd15)%4'd5)) named();
 initial begin #1;$display("T|dependent %0d %0d %0d %0d %0d",F,A[0],d.P,named.P,f());$finish;end
endmodule
