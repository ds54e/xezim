`timescale 1ns/1ps
// IEEE 1800-2023 §11.4.14: reorder first, then zero-fill on the right.
// §6.8/§4.7: declaration initialization uses constants; sample after updates.
module stream_sink(input logic [63:0] value);
endmodule
module top;
  int x;
  logic [11:0] nib_source;
  logic [6:0] odd;
  logic [15:0] tail;
  logic [7:0] unknown;
  typedef struct packed { logic [7:0] hi, lo; } pair_t;
  pair_t pair;
  longint continuous_value, procedural_value, fallback_value;
  logic [63:0] reversed, bytes_reversed, forward_slice, identity_slice;
  logic [23:0] nibble, remainder, multi;
  logic [15:0] odd_reversed;
  int exact, signed_wide;
  logic [127:0] huge;
  logic [31:0] struct_value;
  logic [15:0] four_state;
  bit clk;
  longint comb_value, edge_blocking, edge_nonblocking, part_value, loop_value;
  longint ternary_value;
  always_comb begin
    comb_value = {>>{x}};
    part_value = '1;
    part_value[31:0] = {>>{x}};
    ternary_value = clk ? {>>{x}} : 32'hdeadbeef;
  end
  // §9.2.2/§10.4: stimulus and sampling are separated from this edge.
  always @(posedge clk) edge_blocking = {>>{x}};
  always @(posedge clk) edge_nonblocking <= {>>{x}};
  longint declared = {>>{32'h12345678}};
  assign continuous_value = {>>{x}};
  stream_sink child(.value({>>{x}}));
  function automatic longint by_return(input int v);
    return {>>{v}};
  endfunction
  function automatic longint by_name(input int v);
    by_name = {<<8{v}};
  endfunction
  assign reversed = {<<{x}};
  assign bytes_reversed = {<<8{x}};
  assign forward_slice = {>>4{x}};
  assign identity_slice = {<<64{x}};
  assign nibble = {<<4{nib_source}};
  assign remainder = {<<5{nib_source}};
  assign odd_reversed = {<<3{odd}};
  assign multi = {>>{nib_source, odd}};
  assign exact = {<<8{x}};
  assign huge = {<<8{x, tail}};
  assign struct_value = {<<8{pair}};
  assign four_state = {>>{unknown}};
  initial begin
    x = 32'h12345678; nib_source = 12'ha5c; odd = 7'h5a;
    tail = 16'h9abc; pair = 16'h81a5; unknown = 8'b10xz0011;
    procedural_value = {>>{x}};
    fallback_value = {>>{x+0}};
    signed_wide = {>>{8'shff}};
    for (int i = 0; i < 3; i++) loop_value = {>>{x}};
    #1 clk = 1;
    #1;
    $display("continuous=%h procedural=%h", continuous_value, procedural_value);
    $display("bits=%h bytes=%h forward4=%h identity64=%h", reversed, bytes_reversed, forward_slice, identity_slice);
    $display("nibble=%h remainder=%h odd=%h multi=%h exact=%h", nibble, remainder, odd_reversed, multi, exact);
    $display("huge=%h struct=%h four_state=%b signed=%h", huge, struct_value, four_state, signed_wide);
    $display("declared=%h return=%h named=%h port=%h", declared, by_return(x), by_name(x), child.value);
    // §6.24.3/§11.4.14: a cast makes a stream legal within an expression.
    $display("cast_expr=%h cast_concat=%h fallback=%h", int'({>>{x}}) | 64'h55, {32'hfedcba98, int'({<<8{x}})}, fallback_value);
    $display("comb=%h edge_blocking=%h edge_nonblocking=%h part=%h loop=%h ternary=%h", comb_value, edge_blocking, edge_nonblocking, part_value, loop_value, ternary_value);
    $finish;
  end
endmodule
