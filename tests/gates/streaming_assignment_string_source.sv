`timescale 1ns/1ps
// IEEE 1800-2023 §6.16/§6.24.3/§11.4.14: string source width is dynamic.
module stream_string_child(input int n, output wire [2047:0] value, output longint scope_integer);
  string words;
  longint alias_ca;
  assign value = {>>{words}};
  always_comb alias_ca = n << 32;
  assign scope_integer = alias_ca;
  initial words = {256{"A"}};
endmodule
module top;
  typedef string text_t;
  text_t alias_ca, alias_comb;
  wire [15:0] bits16 = 16'h4142;
  assign alias_ca = {>>{bits16}};
  always_comb alias_comb = {>>{bits16}};
  class source_object;
    logic [127:0] data = 128'h1;
  endclass
  source_object obj;
  wire [127:0] class_source = {>>{obj}};
  string small_text, text, large_text, copy_ca, copy_comb;
  wire [15:0] small_value = {>>{small_text}};
  wire [63:0] exact_value = {>>{text}};
  wire [2047:0] large_value = {>>{large_text}};
  wire [2047:0] rooted_value = {>>{$root.top.large_text}};
  wire [2047:0] child_value;
  wire [63:0] scope_integer;
  stream_string_child child(.n(32'h12345678), .value(child_value), .scope_integer(scope_integer));
  assign copy_ca = {>>{small_text}};
  always_comb copy_comb = {>>{small_text}};
  logic [4095:0] part_value;
  always_comb begin
    part_value = '1;
    part_value[2047:0] = {>>{large_text}};
  end
  initial begin
    obj = new;
    small_text = "AB"; text = "ABCDEFGH"; large_text = {256{"A"}};
    // §4.7: no other writer; sample after the combinational updates.
    #1;
    $display("small=%h exact_string=%h copy_ca=%s/%0d copy_comb=%s/%0d", small_value, exact_value, copy_ca, copy_ca.len(), copy_comb, copy_comb.len());
    $display("large_high=%h large_low=%h part_high=%h part_low=%h", large_value[2047:2016], large_value[31:0], part_value[4095:4064], part_value[31:0]);
    $display("root_high=%h root_low=%h child_high=%h child_low=%h", rooted_value[2047:2016], rooted_value[31:0], child_value[2047:2016], child_value[31:0]);
    $display("alias_ca=%0s/%0d alias_comb=%0s/%0d class_source=%h scope_integer=%h", alias_ca, alias_ca.len(), alias_comb, alias_comb.len(), class_source, scope_integer);
    $finish;
  end
endmodule
