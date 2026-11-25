use super::nettype_array_drivers::check;

#[test]
fn variable_driver_delay_is_preserved_for_array_cells() {
    // §10.3.3: the second driver arrives two ns after each RHS change.
    // Sample at 1, 3, 5, and 7 ns around the updates at 2 and 6 ns (§4.7).
    check(
        r#"
module top;
  import p::*;
  N a[1];
  int dv = 2;
  real v = 2.5;
  assign a = '{1.0};
  assign #(dv) a = '{v};
  real a1, a3, a5;
  initial begin
    #1;
    a1 = a[0];
    #2;
    a3 = a[0];
    #1 v = 7.0;
    #1;
    a5 = a[0];
    #2;
    $display("R %g %g %g %g", a1, a3, a5, a[0]);
    $finish;
  end
endmodule
"#,
        "R 11 13.5 13.5 18",
    );
}

#[test]
fn child_delay_stage_preserves_compilation_unit_variable() {
    // §5.6.1, §3.12.1: the escaped name in the child refers to the
    // compilation-unit variable. The staged driver must use a different name.
    check(
        r#"
real \o[0]$drv0  = 78.0;
module source import p::*; (inout N o[1]);
  assign o = '{1.0};
  real seen;
  initial #3 seen = \o[0]$drv0 ;
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
    $display("R %g %g %g %g", early, a[0], s.o[0], s.seen);
    $finish;
  end
endmodule
"#,
        "R 11 13.5 13.5 78",
    );
}
