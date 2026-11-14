`timescale 1ns/1ps
// IEEE 1800-2023 §13.4.3, §6.16 and §7.12.3: pure constant
// functions may operate on their local strings and unpacked arrays.
// §6.24.1 / §20.5: a new named-cast path must retain unresolved-call
// fallbacks that already give the correct one-bit declaration range.
module top;
  typedef int I;
  function automatic real literal_one(); return 1.0; endfunction
  function automatic int array_one();
    int a[2];
    a[0] = 1;
    a[1] = 0;
    return a.sum();
  endfunction
  function automatic int string_one();
    string s = "x";
    return s.len();
  endfunction
  function automatic int seven();
    int a[1];
    a[0] = 7;
    return a.sum();
  endfunction
  typedef logic [seven():0] V;
  // §6.12.1 / §20.5: $itor takes an integral argument; retain these
  // correct results without broadening computed named-cast operands.
  localparam int HOST = $rtoi(I'(3.5) + $itor(0.4) + 0.6);
  localparam real HOST_ATAN = $atan2(I'(3.5), $itor(0.5) + 3.0);
  localparam int COMPUTED_ITOR = $rtoi(I'($itor(0.4) + 2.2));
  localparam int COMPUTED_CAST = $rtoi(I'(real'(int'(0.49999999999999994)) + 2.5));
  localparam int ROUNDED_DOWN = $rtoi(V'(3.2));
  logic [$rtoi(I'(literal_one()))-1:0] a;
  logic [$rtoi(I'(array_one()))-1:0] b;
  logic [$rtoi(I'(string_one()))-1:0] c;
  // The existing function-call path remains admitted without a named cast.
  function automatic int four(); return 4; endfunction
  logic [$rtoi(four())-1:0] d;
  initial begin
    if ($bits(a) == 1) $display("PASS literal_fallback"); else $display("FAIL literal_fallback");
    if ($bits(b) == 1) $display("PASS array_fallback"); else $display("FAIL array_fallback");
    if ($bits(c) == 1) $display("PASS string_fallback"); else $display("FAIL string_fallback");
    if (HOST == 4 && HOST_ATAN > 0.78539 && HOST_ATAN < 0.78540) $display("PASS host_fallback"); else $display("FAIL host_fallback");
    if (COMPUTED_ITOR == 2 && COMPUTED_CAST == 3) $display("PASS computed_fallback"); else $display("FAIL computed_fallback");
    if (ROUNDED_DOWN == 3) $display("PASS bound_fallback"); else $display("FAIL bound_fallback");
    if ($bits(d) == 4) $display("PASS existing_call"); else $display("FAIL existing_call");
    $finish;
  end
endmodule
