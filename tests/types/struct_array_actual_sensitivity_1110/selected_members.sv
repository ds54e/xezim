// §7.2, §7.4.2, §10.3.2: selected elements and nested members.
`timescale 1ns/1ps
typedef struct { logic [7:0] v; int tag; } S;
function automatic logic [7:0] f(input S x); return x.v; endfunction
module top;
 S a[3:2]; int k; logic[7:0] named_element,root_element,dynamic_element;
 assign named_element=f(.x(a[2]));
 assign root_element=f($root.top.a[2]);
 assign dynamic_element=f(.x(a[k]));
 initial begin
 #1 k=2; a[3]='{8'h80,0}; a[2]='{8'h12,0};
 #1 $display("T|init %h %h %h",named_element,root_element,dynamic_element);
 #1 a[2].v=8'hxz;
 #1 $display("T|xz %h %h %h",named_element,root_element,dynamic_element);
 #1 a[2]='{8'hfe,1};
 #1 $display("T|whole %h %h %h",named_element,root_element,dynamic_element);
 #1 k=3;
 #1 $display("T|index %h %h %h",named_element,root_element,dynamic_element);
 $finish; end
endmodule
