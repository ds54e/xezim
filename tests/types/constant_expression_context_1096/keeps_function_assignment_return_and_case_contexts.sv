// IEEE 1800-2023 §10.8: "A return statement in a function" is assignment-like; §12.5 sizes case selector with the int case items; §11.8.2 propagates 32 bits, giving -2/-6 and selecting -2.
// Constant function returns, function-name/local assignments, case selector and dependent dimensions must agree with runtime.
`timescale 1ns/1ps
module top;
 function automatic int ret_d();return 4'sd3-(1 ? 4'sd5 : 4'd0);endfunction
 function automatic int old_d();old_d=4'sd3-(1 ? 4'sd5 : 4'd0);endfunction
 function automatic int temp_d();int t;t=4'sd3-(1 ? 4'sd5 : 4'd0);return t;endfunction
 function automatic int temp_m();int t;t=(1 ? -4'sd2 : 4'd0)*4'sd3;return t;endfunction
 function automatic int choose();case(4'sd3-(1 ? 4'sd5 : 4'd0)) -2:return 1;14:return 2;default:return 3;endcase endfunction
 localparam int R=ret_d(),O=old_d(),D=temp_d(),M=temp_m(),K=choose();
 logic [R+8:0] vec;
 initial begin #1;$display("T|constant %0d %0d %0d %0d %0d %0d",R,O,D,M,K,$bits(vec));
 $display("T|runtime %0d %0d %0d %0d %0d",ret_d(),old_d(),temp_d(),temp_m(),choose());$finish;end
endmodule
