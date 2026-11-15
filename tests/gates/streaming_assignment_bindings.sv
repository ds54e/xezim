`timescale 1ns/1ps
// IEEE 1800-2023 §23.9/§8.23/§11.4.14: stream the resolved binding.
package stream_bindings;
  function automatic int pf(input int v); return {>>{v}}; endfunction
  class C;
    int v;
    static function int sf(input int v); return {>>{v}}; endfunction
    function int mf(input int v); return {>>{v}}; endfunction
    function int prop(); return {>>{v}}; endfunction
  endclass
endpackage
module top;
  byte v;
  logic [15:0] h16;
  int q_loop, q_fn, q_named, q_pkg, q_static, q_formal, q_prop, q_local;
  int q_reverse_loop, q_reverse_fn;
  int q_reverse_const;
  longint q_wide, q_target;
  string s_ca, s_comb, s_star, s_loop, s_reverse;
  string method_string, method_string_reverse;
  class range_source;
    logic [3:0][31:0] v;
    // §7.4.3: all four packed words, 128 bits, with value 5.
    function logic [127:0] read_words(); return {>>{v[3:0]}}; endfunction
  endclass
  class string_source;
    logic [15:0] v;
    function void capture();
      method_string = {>>{v}};
      method_string_reverse = {<<8{v}};
    endfunction
  endclass
  range_source range_obj;
  string_source string_obj;
  logic [127:0] member_range;
  stream_bindings::C obj;
  function automatic int fn(input int v); return {>>{v}}; endfunction
  function automatic int named(input int v); named = {>>{v}}; endfunction
  function automatic int local_fn(input int n);
    int v; v = n; return {>>{v}};
  endfunction
  function automatic int rev(input int v); return {<<8{v}}; endfunction
  function automatic longint wide(input int v); return {>>{v}}; endfunction
  function automatic int constant_fn();
    localparam int v = 32'h89abcdef;
    return {<<8{v}};
  endfunction
  function automatic longint target_shadow(input int n);
    longint s_ca;
    s_ca = n << 32;
    return s_ca;
  endfunction
  // §6.16/§6.24.3/§11.4.14: a string is dynamically sized, not 1024 bits.
  assign s_ca = {>>{h16}};
  always_comb s_comb = {>>{h16}};
  always @* s_star = {>>{h16}};
  always_comb s_reverse = {<<8{h16}};
  initial begin
    v = 8'h5a; h16 = 16'h4142;
    obj = new; obj.v = 32'h89abcdef;
    range_obj = new; range_obj.v = 128'h5;
    string_obj = new; string_obj.v = 16'h4141;
    for (int v = 32'h89abcdee; v < 32'h89abcdf0; v++) begin
      q_loop = {>>{v}};
      q_reverse_loop = {<<8{v}};
    end
    // Exercise compiled methods as well as their cold interpreted calls.
    for (int i = 0; i < 1500; i++) begin
      q_fn = fn(32'h89abcdef); q_named = named(32'h89abcdef);
      q_pkg = stream_bindings::pf(32'h89abcdef);
      q_static = stream_bindings::C::sf(32'h89abcdef);
      q_formal = obj.mf(32'h89abcdef); q_prop = obj.prop();
      q_local = local_fn(32'h89abcdef);
      q_reverse_fn = rev(32'h89abcdef); q_wide = wide(32'h89abcdef);
      q_reverse_const = constant_fn(); q_target = target_shadow(32'h12345678);
      member_range = range_obj.read_words(); string_obj.capture();
    end
    for (int i = 0; i < 3; i++) s_loop = {>>{h16}};
    // §4.7: sample after combinational updates settle.
    #1;
    $display("loop=%h function=%h named=%h package=%h static=%h formal=%h property=%h local=%h", q_loop, q_fn, q_named, q_pkg, q_static, q_formal, q_prop, q_local);
    $display("reverse_loop=%h reverse_function=%h wide=%h", q_reverse_loop, q_reverse_fn, q_wide);
    $display("reverse_constant=%h shadow_target=%h", q_reverse_const, q_target);
    $display("member_range=%h method_string=%s/%0d method_string_reverse=%s/%0d", member_range, method_string, method_string.len(), method_string_reverse, method_string_reverse.len());
    $display("string_ca=%s/%0d string_comb=%s/%0d string_star=%s/%0d string_loop=%s/%0d string_reverse=%s/%0d equal=%0d", s_ca, s_ca.len(), s_comb, s_comb.len(), s_star, s_star.len(), s_loop, s_loop.len(), s_reverse, s_reverse.len(), s_comb == "AB");
    $finish;
  end
endmodule
