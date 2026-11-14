`timescale 1ns/1ps
// IEEE 1800-2023 §§7.2.1, 11.6, 11.8.1–11.8.4.
module top;
  typedef struct packed { logic signed [7:0] a; logic [7:0] pad; } S;
  S s;
  S arr[0:0];
  logic [15:0] dotted, direct, mixed, part;
  logic [127:0] wide;
  logic [15:0] proc_dotted, proc_direct;
  assign dotted = s.a;
  assign direct = arr[0].a;
  assign wide = s.a;
  assign mixed = s.a & 16'hffff;
  assign part = s.a[7:0];
  task check(input string label_, input logic [127:0] got, expected);
    $display("%s %s got=%b expected=%b",got === expected ? "PASS" : "FAIL",label_,got,expected);
  endtask
  initial begin
    s.pad = 0; arr[0].pad = 0;
    s.a = 8'bx0000001; arr[0].a = 8'bx0000001;
    #1;
    proc_dotted = s.a; proc_direct = arr[0].a;
    check("x_dotted", {112'b0,dotted}, {112'b0,{9{1'bx}},7'b0000001});
    check("x_direct", {112'b0,direct}, {112'b0,{9{1'bx}},7'b0000001});
    check("x_wide", wide, {{121{1'bx}},7'b0000001});
    check("x_procedural_dotted", {112'b0,proc_dotted}, {112'b0,{9{1'bx}},7'b0000001});
    check("x_procedural_direct", {112'b0,proc_direct}, {112'b0,{9{1'bx}},7'b0000001});
    check("unsigned_context", {112'b0,mixed}, {120'b0,8'bx0000001});
    check("unsigned_part", {112'b0,part}, {120'b0,8'bx0000001});
    s.a = 8'bz0000001; arr[0].a = 8'bz0000001;
    #1;
    check("z_dotted", {112'b0,dotted}, {112'b0,{9{1'bz}},7'b0000001});
    check("z_direct", {112'b0,direct}, {112'b0,{9{1'bz}},7'b0000001});
    check("z_wide", wide, {{121{1'bz}},7'b0000001});
    $finish;
  end
endmodule
