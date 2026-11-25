use super::nettype_array_drivers::check;

#[test]
fn array_delay_stage_preserves_compilation_unit_let() {
    // §5.6.1, §3.12.1, §11.12: the escaped let name denotes the
    // compilation-unit expression when read from the connected child.
    check(
        r#"
let \o[0]$drv0  = 63;
module source import p::*; (inout N o[1]);
  assign o = '{1.0};
  int guard;
  initial #3 guard = \o[0]$drv0 ;
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
        "R 11 13.5 13.5 guard 63",
    );
}

#[test]
fn array_delay_stage_uses_generate_block_variable() {
    // §10.3.3, §27.5: g.dv supplies the two-ns delay. The samples
    // straddle that update without coinciding with it (§4.7).
    check(
        r#"
module top;
  import p::*;
  int dv = 8;
  if (1) begin : g
    N a[1];
    int dv = 2;
    real v = 2.5;
    assign a = '{1.0};
    assign #(dv) a = '{v};
  end
  real early;
  initial begin
    #1 early = g.a[0];
    #2;
    $display("R %g %g", early, g.a[0]);
    $finish;
  end
endmodule
"#,
        "R 11 13.5",
    );
}
