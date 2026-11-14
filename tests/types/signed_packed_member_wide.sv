`timescale 1ns/1ps
// IEEE 1800-2023 §§7.2.1, 7.4.1, 11.8.3–11.8.4.
module top;
 typedef struct packed {logic signed [79:0] f; logic [7:0] pad;} S;
 S s;
 logic [127:0] wide_q, part_q;
 logic [79:0] same_q;
 logic [7:0] narrow_q;
 assign wide_q=s.f; assign part_q=s.f[79:0]; assign same_q=s.f; assign narrow_q=s.f;
 task check(input string label_,input logic [127:0] got,expected);
  $display("%s %s got=%h expected=%h",got===expected?"PASS":"FAIL",label_,got,expected);
 endtask
 initial begin
  s='0; s.f=-2;
  #1;
  check("wide_member",wide_q,128'hfffffffffffffffffffffffffffffffe);
  check("wide_part",part_q,128'h000000000000fffffffffffffffffffe);
  check("same_width",{48'b0,same_q},128'h000000000000fffffffffffffffffffe);
  check("narrow_width",narrow_q,128'hfe);
  $finish;
 end
endmodule
