//! IEEE 1800-2023 §6.6.7 and §6.7.2: a resolved nettype array has a driver
//! list per element. Matching nettype ports merge corresponding nets (§23.3.3).
//! Sample after the drivers have settled (§4.7).

use xezim::simulate;

const PACKAGE: &str = r#"
`timescale 1ns/1ps
package p;
  localparam real VALUE = 2.0;
  function automatic real fold(input real drivers[]);
    fold = 10.0;
    foreach (drivers[i]) fold += drivers[i];
  endfunction
  nettype real N with fold;
endpackage
"#;

pub(super) fn check(body: &str, expected: &str) {
    check_design(&[PACKAGE, body].concat(), expected);
}

fn check_design(source: &str, expected: &str) {
    let result = simulate(source, 10_000_000).expect("simulate failed");
    let output: Vec<_> = result
        .output
        .iter()
        .map(|line| line.message.trim())
        .filter(|line| line.starts_with("R "))
        .collect();
    assert_eq!(output, [expected]);
}

#[test]
fn whole_output_array_drives_parent_and_child_cells() {
    check(
        r#"
module source import p::*; (output N o[1]);
  assign o = '{1.0};
endmodule
module top;
  import p::*;
  N a[1];
  source s(a);
  initial begin
    #1;
    $display("R %g %g", a[0], s.o[0]);
    $finish;
  end
endmodule
"#,
        "R 11 11",
    );
}

#[test]
fn output_order_follows_both_declared_ranges() {
    // §7.6, §10.9.1: positional and keyed patterns both follow the selected
    // element, and the port pairs elements in declared left-to-right order.
    check(
        r#"
module descending import p::*; (output N o[6:5]);
  assign o = '{1.0, VALUE};
endmodule
module ascending import p::*; #(parameter int LEFT = 0) (output N o[LEFT:LEFT+1]);
  assign o = '{LEFT+1:p::VALUE, default:1.0};
endmodule
module top;
  import p::*;
  N a[0:1], b[1:0];
  descending d(a);
  ascending #(.LEFT(5)) u(b);
  initial begin
    #1;
    $display("R %g %g %g %g %g %g %g %g",
             a[0], a[1], d.o[6], d.o[5], b[1], b[0], u.o[5], u.o[6]);
    $finish;
  end
endmodule
"#,
        "R 11 12 11 12 11 12 11 12",
    );
}

#[test]
fn inout_collects_both_drivers_per_cell() {
    // §10.9.1: the parameterized replication fills the child's whole array.
    check(
        r#"
module source import p::*; #(parameter int COUNT = 1) (inout N o[COUNT]);
  assign o = '{COUNT{1.0}};
endmodule
module top;
  import p::*;
  N a[2];
  assign a = '{2.0, 3.0};
  source #(.COUNT(2)) s(a);
  initial begin
    #1;
    $display("R %g %g %g %g", a[0], a[1], s.o[0], s.o[1]);
    $finish;
  end
endmodule
"#,
        "R 13 14 13 14",
    );
}

#[test]
fn array_body_copy_resolves_source_and_destination_separately() {
    // §7.6, §10.3: a body copy reads the source's resolved value and
    // contributes it as a driver of the destination. simulate() exercises
    // the lazy source path, where the body assignment's origin is retained.
    check(
        r#"
module source import p::*; (output N o[1:0]);
  N b[5:6];
  assign b = '{1.0, 2.0};
  assign o = b;
endmodule
module top;
  import p::*;
  N a[2];
  source s(a);
  initial begin
    #1;
    $display("R %g %g %g %g %g %g", a[0], a[1], s.o[1], s.o[0], s.b[5], s.b[6]);
    $finish;
  end
endmodule
"#,
        "R 21 22 21 22 11 12",
    );
}

#[test]
fn internal_int_array_resolves_each_element() {
    check_design(
        r#"
`timescale 1ns/1ps
package q;
  function automatic int fold(input int drivers[]);
    fold = 10;
    foreach (drivers[i]) fold += drivers[i];
  endfunction
  nettype int N with fold;
endpackage
module source;
  import q::*;
  N a[2];
  assign a = '{1, 2};
endmodule
module top;
  source s();
  initial begin
    #1;
    $display("R %0d %0d", s.a[0], s.a[1]);
    $finish;
  end
endmodule
"#,
        "R 11 12",
    );
}

#[test]
fn packed_vector_output_resolves_each_element() {
    check_design(
        r#"
`timescale 1ns/1ps
package q;
  typedef logic [7:0] octet_t;
  function automatic octet_t fold(input octet_t drivers[]);
    fold = 8'd10;
    foreach (drivers[i]) fold += drivers[i];
  endfunction
  nettype octet_t N with fold;
endpackage
module source import q::*; (output N o[2]);
  assign o = '{8'd149, 8'd2};
endmodule
module top;
  import q::*;
  N a[2];
  source s(a);
  initial begin
    #1;
    $display("R %0d %0d %0d %0d", a[0], a[1], s.o[0], s.o[1]);
    $finish;
  end
endmodule
"#,
        "R 159 12 159 12",
    );
}

#[test]
fn signed_vector_output_resolves_each_element() {
    // §6.11.3, §10.9.1: the first driver is -1 in the signed element type.
    check_design(
        r#"
`timescale 1ns/1ps
package q;
  typedef logic signed [15:0] word_t;
  function automatic word_t fold(input word_t drivers[]);
    fold = 16'sd10;
    foreach (drivers[i]) fold += drivers[i];
  endfunction
  nettype word_t N with fold;
endpackage
module source import q::*; (output N o[2]);
  assign o = '{-16'sd1, 16'sd2};
endmodule
module top;
  import q::*;
  N a[2];
  source s(a);
  initial begin
    #1;
    $display("R %0d %0d %0d %0d", a[0], a[1], s.o[0], s.o[1]);
    $finish;
  end
endmodule
"#,
        "R 9 12 9 12",
    );
}

#[test]
fn packed_struct_output_resolves_each_element() {
    // §7.2.1, §10.9.1: each array element drives a whole packed structure.
    check_design(
        r#"
`timescale 1ns/1ps
package q;
  typedef struct packed { logic [7:0] value; } record_t;
  function automatic record_t fold(input record_t drivers[]);
    fold = record_t'(8'd10);
    foreach (drivers[i]) fold.value += drivers[i].value;
  endfunction
  nettype record_t N with fold;
endpackage
module source import q::*; (output N o[2]);
  assign o = '{record_t'(8'd1), record_t'(8'd2)};
endmodule
module top;
  import q::*;
  N a[2];
  source s(a);
  initial begin
    #1;
    $display("R %0d %0d %0d %0d", a[0].value, a[1].value, s.o[0].value, s.o[1].value);
    $finish;
  end
endmodule
"#,
        "R 11 12 11 12",
    );
}

#[test]
fn shortreal_output_resolves_each_element() {
    check_design(
        r#"
`timescale 1ns/1ps
package q;
  function automatic shortreal fold(input shortreal drivers[]);
    fold = 10.0;
    foreach (drivers[i]) fold += drivers[i];
  endfunction
  nettype shortreal N with fold;
endpackage
module source import q::*; (output N o[2]);
  assign o = '{1.5, 2.25};
endmodule
module top;
  import q::*;
  N a[2];
  source s(a);
  initial begin
    #1;
    $display("R %g %g", a[0], a[1]);
    $finish;
  end
endmodule
"#,
        "R 11.5 12.25",
    );
}

#[test]
fn whole_array_drive_reads_rhs_slice_in_order() {
    // §7.4.5, §7.6, §10.3.2: each destination net follows the
    // corresponding element of the slice in left-to-right order.
    check(
        r#"
module source import p::*; (output N o[0:1]);
  real b[5:2];
  initial b = '{0.0, 1.0, 2.0, 0.0};
  assign o = b[4:3];
endmodule
module top;
  import p::*;
  N a[1:0];
  source s(a);
  initial begin
    #1;
    $display("R %g %g %g %g", a[1], a[0], s.o[0], s.o[1]);
    $finish;
  end
endmodule
"#,
        "R 11 12 11 12",
    );
}

#[test]
fn whole_array_drive_reads_rhs_concatenation_in_order() {
    // §10.10, §7.6: each input array contributes its elements in order.
    check(
        r#"
module source import p::*; (output N o[2]);
  real ra[1] = '{1.0}, rb[1] = '{2.0};
  assign o = {ra, rb};
endmodule
module top;
  import p::*;
  N a[2];
  source s(a);
  initial begin
    #1;
    $display("R %g %g %g %g", a[0], a[1], s.o[0], s.o[1]);
    $finish;
  end
endmodule
"#,
        "R 11 12 11 12",
    );
}

#[test]
fn delayed_parent_drive_updates_a_cell_with_an_undelayed_child() {
    // §10.3.3: only the parent's contribution is delayed. Both resolvers
    // see that contribution at the second sample, even for the zero child.
    check(
        r#"
module source import p::*; #(parameter real V = 0.0) (inout N o[1]);
  assign o = '{V};
endmodule
module top;
  import p::*;
  N a[1], b[1];
  source zero(a);
  source #(.V(1.0)) one(b);
  assign #2 a = '{2.5};
  assign #2 b = '{2.5};
  real early_a, early_b;
  initial begin
    #1;
    early_a = a[0];
    early_b = b[0];
    #2;
    $display("R %g %g %g %g", early_a, early_b, a[0], b[0]);
    $finish;
  end
endmodule
"#,
        "R 10 11 12.5 13.5",
    );
}

#[test]
fn scalar_body_copy_and_top_array_still_resolve() {
    check(
        r#"
module source import p::*; (output N o);
  N b;
  assign b = 1.0;
  assign o = b;
endmodule
module top;
  import p::*;
  N a, top_array[1];
  assign top_array = '{1.0};
  source s(a);
  initial begin
    #1;
    $display("R %g %g %g %g", a, s.o, s.b, top_array[0]);
    $finish;
  end
endmodule
"#,
        "R 21 21 11 11",
    );
}

#[test]
fn ordinary_and_unresolved_real_outputs_still_copy_in_order() {
    check(
        r#"
nettype real U;
module ordinary(output real o[6:5]);
  assign o = '{1.0, 2.0};
endmodule
module unresolved(output U o[6:5]);
  assign o = '{3.0, 4.0};
endmodule
module top;
  real a[1:0];
  U b[1:0];
  ordinary s(a);
  unresolved u(b);
  initial begin
    #1;
    $display("R %g %g %g %g", a[1], a[0], b[1], b[0]);
    $finish;
  end
endmodule
"#,
        "R 1 2 3 4",
    );
}

#[test]
fn top_array_resolves_undelayed_and_delayed_drives() {
    // §10.3.3: the delay applies to the second driver before resolution.
    check(
        r#"
module top;
  import p::*;
  N a[1];
  assign a = '{1.0};
  assign #2 a = '{2.5};
  real early;
  initial begin
    #1;
    early = a[0];
    #2;
    $display("R %g %g", early, a[0]);
    $finish;
  end
endmodule
"#,
        "R 11 13.5",
    );
}

#[test]
fn scalar_delay_stage_preserves_escaped_declarations() {
    // §5.6.1, §10.3.3: the driver's stage must have separate storage
    // from the escaped names in the two instances.
    check(
        r#"
module source import p::*; (inout N o);
  real \o$drv0  = 78.0;
  assign o = 1.0;
endmodule
module top;
  import p::*;
  N a;
  real \a$drv0  = 77.0;
  source s(a);
  assign #2 a = 2.5;
  real early;
  initial begin
    #1;
    early = a;
    #2;
    $display("R %g %g %g %g %g", early, a, s.o, \a$drv0 , s.\o$drv0 );
    $finish;
  end
endmodule
"#,
        "R 11 13.5 13.5 77 78",
    );
}
