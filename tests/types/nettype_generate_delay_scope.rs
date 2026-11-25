use super::nettype_array_drivers::check;

#[test]
fn array_delay_uses_each_generate_iterations_variable() {
    // §23.9, §27.4: each iteration's dv shadows the module's variable.
    // §10.3.3: sample before, between and after the 2 ns and 4 ns updates.
    check(
        r#"
module top;
  import p::*;
  int dv = 8;
  for (genvar i = 0; i < 2; i++) begin : g
    int dv = i == 0 ? 2 : 4;
    N a[1];
    assign a = '{1.0};
    assign #(dv) a = '{2.5};
  end
  real a1, b1, a3, b3;
  initial begin
    #1;
    a1 = g[0].a[0];
    b1 = g[1].a[0];
    #2;
    a3 = g[0].a[0];
    b3 = g[1].a[0];
    #2;
    $display("R %g %g %g %g %g %g", a1, b1, a3, b3, g[0].a[0], g[1].a[0]);
    $finish;
  end
endmodule
"#,
        "R 11 11 13.5 11 13.5 13.5",
    );
}

#[test]
fn array_delay_expression_uses_the_implicit_genvar_localparam() {
    // §27.4: i is the integer localparam of the current iteration.
    // §10.3.3: base_d + i * 2 delays the second driver by 2 ns or 4 ns.
    check(
        r#"
module top;
  import p::*;
  int base_d = 2;
  for (genvar i = 0; i < 2; i++) begin : g
    N a[1];
    assign a = '{1.0};
    assign #(base_d + i * 2) a = '{2.5};
  end
  real a1, b1, a3, b3;
  initial begin
    #1;
    a1 = g[0].a[0];
    b1 = g[1].a[0];
    #2;
    a3 = g[0].a[0];
    b3 = g[1].a[0];
    #2;
    $display("R %g %g %g %g %g %g", a1, b1, a3, b3, g[0].a[0], g[1].a[0]);
    $finish;
  end
endmodule
"#,
        "R 11 11 13.5 11 13.5 13.5",
    );
}

#[test]
fn array_delay_stage_preserves_compilation_unit_typedef() {
    // §3.12.1, §5.6.1, §6.18: the escaped name denotes the unit typedef.
    // §6.24.1, §20.6.2: the guard adds the cast value (78) to the width (16).
    check(
        r#"
typedef logic [15:0] \o[0]$drv0 ;
module source import p::*; (inout N o[1]);
  assign o = '{1.0};
  \o[0]$drv0  v = 16'd78;
  int guard;
  initial #3 guard = int'(\o[0]$drv0 '(v)) + $bits(\o[0]$drv0 );
endmodule
module top;
  import p::*;
  N a[1];
  source s(a);
  assign #2 a = '{2.5};
  real early;
  initial begin
    #1 early = a[0];
    #3;
    $display("R %g %g %g guard %0d", early, a[0], s.o[0], s.guard);
    $finish;
  end
endmodule
"#,
        "R 11 13.5 13.5 guard 94",
    );
}
