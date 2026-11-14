`timescale 1ns/1ps
// IEEE 1800-2023 §6.24.1 / §6.12.1: integral casts round ties away
// from zero; §20.5: $rtoi truncates the converted argument.
package cast_pkg;
  typedef int I;
endpackage
module top;
  typedef int I;
  typedef byte B;
  typedef shortint S;
  typedef longint L;
  typedef integer G;
  typedef I Alias;
  typedef logic [7:0] V;
  typedef logic signed [7:0] VS;
  typedef int unsigned U;
  localparam int PI = $rtoi(I'(3.5));
  localparam int PB = $rtoi(B'(3.5));
  localparam int PS = $rtoi(S'(-3.5));
  localparam int PL = $rtoi(L'(3.5));
  localparam int PG = $rtoi(G'(3.5));
  localparam int PA = $rtoi(Alias'(3.5));
  localparam int PP = $rtoi(cast_pkg::I'(3.5));
  localparam int PV = $rtoi(V'(-3.5));
  localparam int PVS = $rtoi(VS'(-3.5));
  localparam int PU = $rtoi(U'(3.5));
  localparam int PN = $rtoi(I'(-3.5));
  localparam int PT = $rtoi(B'(259.5));
  parameter int DEFAULT = $rtoi(I'(3.5));
  localparam real A = 1.5, C = 2.0;
  localparam int PLAIN = $rtoi(3.5);
  localparam int EXPR = $rtoi(A + C);
  localparam int ITOR = $rtoi($itor(4));
  localparam int BUILTINS = $rtoi(int'(3.5)) + $rtoi(byte'(3.5))
      + $rtoi(shortint'(-3.5)) + $rtoi(longint'(3.5)) + $rtoi(integer'(3.5));
  localparam int BELOW_HALF = $rtoi(I'(0.49999999999999994));
  localparam int HUGE = $rtoi(I'(1.0e300));
  localparam int INTEGRAL = $rtoi(I'(3));
  // §7.4.1 / §7.4.2, §11.4.12.1 and §20.6.2: dimensions,
  // replication counts and $bits operands are constant expressions.
  logic [$rtoi(I'(3.5))-1:0] packed_value;
  bit unpacked_value [0:$rtoi(I'(3.5))-1];
  localparam REPLICATED = {$rtoi(I'(3.5)){1'b1}};
  localparam int BITS = $bits({$rtoi(I'(3.5)){1'b0}});
  logic [$rtoi(I'(3.5) + 0.5)-1:0] sum_value;
  logic [$rtoi(I'(real'(3.5)))-1:0] nested_value;
  // §20.8.2, Table 20-4: mathematical functions consume the cast result.
  localparam real CEIL = $ceil(I'(3.5));
  localparam real FLOOR = $floor(I'(3.5));
  localparam real SQRT = $sqrt(I'(3.5));
  localparam real LN = $ln(I'(3.5));
  localparam real CONVERT = $itor(I'(3.5));
  initial begin
    localparam int PROC = $rtoi(I'(3.5));
    if (PI == 4) $display("PASS int"); else $display("FAIL int %0d", PI);
    if (PB == 4) $display("PASS byte"); else $display("FAIL byte %0d", PB);
    if (PS == -4) $display("PASS shortint"); else $display("FAIL shortint %0d", PS);
    if (PL == 4) $display("PASS longint"); else $display("FAIL longint %0d", PL);
    if (PG == 4) $display("PASS integer"); else $display("FAIL integer %0d", PG);
    if (PA == 4) $display("PASS alias"); else $display("FAIL alias %0d", PA);
    if (PP == 4) $display("PASS package"); else $display("FAIL package %0d", PP);
    if (PV == 252) $display("PASS unsigned_vector"); else $display("FAIL unsigned_vector %0d", PV);
    if (PVS == -4) $display("PASS signed_vector"); else $display("FAIL signed_vector %0d", PVS);
    if (PU == 4) $display("PASS unsigned_atom"); else $display("FAIL unsigned_atom %0d", PU);
    if (PN == -4) $display("PASS negative"); else $display("FAIL negative %0d", PN);
    if (PT == 4) $display("PASS narrowed"); else $display("FAIL narrowed %0d", PT);
    if (DEFAULT == 4) $display("PASS parameter"); else $display("FAIL parameter %0d", DEFAULT);
    if ($bits(packed_value) == 4) $display("PASS packed"); else $display("FAIL packed %0d", $bits(packed_value));
    if ($size(unpacked_value) == 4) $display("PASS unpacked"); else $display("FAIL unpacked %0d", $size(unpacked_value));
    if ($bits(REPLICATED) == 4) $display("PASS replication"); else $display("FAIL replication %0d", $bits(REPLICATED));
    if (BITS == 4) $display("PASS bits"); else $display("FAIL bits %0d", BITS);
    if ($bits(sum_value) == 4) $display("PASS sum"); else $display("FAIL sum %0d", $bits(sum_value));
    if ($bits(nested_value) == 4) $display("PASS nested"); else $display("FAIL nested %0d", $bits(nested_value));
    if (PROC == 4) $display("PASS procedural_constant"); else $display("FAIL procedural_constant %0d", PROC);
    if ($rtoi(I'(3.5)) == 4) $display("PASS procedural"); else $display("FAIL procedural");
    if (CEIL == 4.0) $display("PASS ceil"); else $display("FAIL ceil %f", CEIL);
    if (FLOOR == 4.0) $display("PASS floor"); else $display("FAIL floor %f", FLOOR);
    if (SQRT == 2.0) $display("PASS sqrt"); else $display("FAIL sqrt %f", SQRT);
    if (LN > 1.38629 && LN < 1.38630) $display("PASS ln"); else $display("FAIL ln %f", LN);
    if (CONVERT == 4.0) $display("PASS itor_cast"); else $display("FAIL itor_cast %f", CONVERT);
    if (PLAIN == 3 && EXPR == 3 && ITOR == 4) $display("PASS real_guards"); else $display("FAIL real_guards");
    if (BUILTINS == 12) $display("PASS builtin_guards"); else $display("FAIL builtin_guards %0d", BUILTINS);
    if (BELOW_HALF == 0 && HUGE == 0) $display("PASS rounding_guards"); else $display("FAIL rounding_guards");
    if (INTEGRAL == 3) $display("PASS integral_guard"); else $display("FAIL integral_guard %0d", INTEGRAL);
    $finish;
  end
endmodule
