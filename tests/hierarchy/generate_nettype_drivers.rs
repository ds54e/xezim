//! IEEE 1800-2023 §6.5 and §6.6.7 allow multiple continuous drivers on a
//! resolved net. Generate blocks can declare these nets (§27.2).

use xezim::simulate;

const REAL_SUM: &str = r#"
function automatic real sum(input real drivers[]);
  sum = 0.0;
  foreach (drivers[k]) sum += drivers[k];
endfunction
nettype real rn with sum;
"#;

fn check(src: &str, expected: &str) {
    let sim = simulate(src, 10).expect("simulate");
    let messages: Vec<_> = sim
        .output
        .iter()
        .map(|line| line.message.as_str())
        .collect();
    assert_eq!(messages, [expected]);
}

fn check_real_net(design: &str, expected: &str) {
    check(&format!("{REAL_SUM}{design}"), expected);
}

#[test]
fn if_generate() {
    check_real_net(
        r#"
module top;
  if (1) begin : G
    rn n;
    assign n = 0.5;
    assign n = 10.0;
  end
  initial #1 $display("n=%0.2f", G.n);
endmodule
"#,
        "n=10.50",
    );
}

#[test]
fn for_generate() {
    // §27.4: each iteration has its own implicit localparam and net.
    check_real_net(
        r#"
module top;
  for (genvar g = 0; g < 2; g++) begin : G
    rn n;
    assign n = g + 0.5;
    assign n = 10.0 * (g + 1);
  end
  initial #1 $display("n=%0.2f %0.2f", G[0].n, G[1].n);
endmodule
"#,
        "n=10.50 21.50",
    );
}

#[test]
fn nested_case_generate() {
    // §27.5: the selected case block is nested in the selected if block.
    check_real_net(
        r#"
module top;
  if (1) begin : Outer
    case (1)
      1: begin : Inner
        rn n;
        assign n = 0.5;
        assign n = 10.0;
        assign n = -2.0;
      end
    endcase
  end
  initial #1 $display("n=%0.2f", Outer.Inner.n);
endmodule
"#,
        "n=8.50",
    );
}

#[test]
fn unpacked_struct_net() {
    // §6.6.7 and §10.3.2: each assignment drives the whole atomic net.
    check(
        r#"
typedef struct { real r; int i; } sample_t;
function automatic sample_t sum(input sample_t drivers[]);
  sum = '{0.0, 0};
  foreach (drivers[k]) begin
    sum.r += drivers[k].r;
    sum.i += drivers[k].i;
  end
endfunction
nettype sample_t sn with sum;
module top;
  if (1) begin : G
    sn n;
    assign n = '{0.5, 1};
    assign n = '{10.0, 2};
  end
  initial #1 $display("n=%0.2f %0d", G.n.r, G.n.i);
endmodule
"#,
        "n=10.50 3",
    );
}

#[test]
fn drivers_inside_and_outside_generate() {
    // §23.6: the hierarchical assignment targets the same net.
    check_real_net(
        r#"
module top;
  if (1) begin : G
    rn n;
    assign n = 0.5;
    assign n = 1.0;
  end
  assign G.n = 10.0;
  initial #1 $display("n=%0.2f", G.n);
endmodule
"#,
        "n=11.50",
    );
}

fn check_delayed_declaration_driver(sample_time: u64, expected: &str) {
    check_real_net(
        &format!(
            r#"
module top;
  if (1) begin : G
    rn #3 n = 0.5;
    assign n = 10.0;
  end
  initial #{sample_time} $display("n=%0.2f", G.n);
endmodule
"#
        ),
        expected,
    );
}

#[test]
fn declaration_driver_contributes_after_its_delay() {
    // §10.3.1 and §10.3.3: the declaration supplies a continuous driver.
    check_delayed_declaration_driver(4, "n=10.50");
}

#[test]
fn declaration_driver_waits_for_its_delay() {
    // §10.3.3: only the undelayed driver has arrived at time 1.
    check_delayed_declaration_driver(1, "n=10.00");
}

#[test]
fn module_typedef_shadows_unit_nettype() {
    // §6.18 and §26.5: the module typedef supplies the variable type.
    check(
        r#"
nettype real T;
module top;
  typedef real T;
  if (1) begin : G
    T v = 0.5;
    T c;
    assign c = v * 2.5;
  end
  initial #1 $display("v=%0.2f c=%0.2f", G.v, G.c);
endmodule
"#,
        "v=0.50 c=1.25",
    );
}

#[test]
fn type_parameter_shadows_unit_nettype() {
    // §6.20.3 and §26.5: the type parameter supplies the variable type.
    check(
        r#"
nettype real T;
module top #(parameter type T = real);
  if (1) begin : G
    T v = 0.5;
    T c;
    assign c = v * 2.5;
  end
  initial #1 $display("v=%0.2f c=%0.2f", G.v, G.c);
endmodule
"#,
        "v=0.50 c=1.25",
    );
}

#[test]
fn module_typedef_shadows_package_nettype() {
    // §6.18 and §26.3: the local typedef takes precedence over p::*.
    check(
        r#"
package p;
  nettype real T;
endpackage
module top;
  import p::*;
  typedef real T;
  if (1) begin : G
    T v = 0.5;
    T c;
    assign c = v * 2.5;
  end
  initial #1 $display("v=%0.2f c=%0.2f", G.v, G.c);
endmodule
"#,
        "v=0.50 c=1.25",
    );
}

#[test]
fn generated_variable_rejects_two_continuous_drivers() {
    // §6.5: a variable allows a single continuous assignment.
    let src = r#"
module top;
  if (1) begin : G
    real v;
    assign v = 0.5;
    assign v = 10.0;
  end
endmodule
"#;
    assert!(simulate(src, 10).is_err(), "accepted:\n{src}");
}

#[test]
fn unresolved_net_rejects_two_continuous_drivers() {
    // §6.6.7: a nettype with no resolution function allows one driver.
    let src = r#"
nettype real un;
module top;
  if (1) begin : G
    un n;
    assign n = 0.5;
    assign n = 10.0;
  end
endmodule
"#;
    assert!(simulate(src, 10).is_err(), "accepted:\n{src}");
}

#[test]
fn generated_wire_resolves_opposing_drivers() {
    // §6.6.1, Table 6-2: opposite drivers of equal strength resolve to X.
    check(
        r#"
module top;
  if (1) begin : G
    wire w;
    assign w = 1'b0;
    assign w = 1'b1;
  end
  initial #1 $display("w=%b", G.w);
endmodule
"#,
        "w=x",
    );
}
