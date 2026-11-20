//! IEEE 1800-2023 §6.5 and §6.6.7 allow multiple continuous drivers on a
//! resolved net. Named generate blocks can declare those nets (§27.2,
//! §27.4, §27.5). Sample after the drivers and readers settle.

const REAL_SUM: &str = r#"
function automatic real rsum(input real drivers[]);
  rsum = 0.0;
  foreach (drivers[k]) rsum += drivers[k];
endfunction
nettype real rn with rsum;
"#;

fn check(src: &str, expected: &str) {
    let result = xezim::simulate(src, 10).expect("simulate");
    let messages: Vec<_> = result.output.iter().map(|o| o.message.as_str()).collect();
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
    // §27.4: the implicit localparam gives each instance its own driver values.
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
fn unpacked_struct_whole_net_drivers() {
    // §6.6.7 and §10.3: each assignment drives the whole atomic net.
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
    // guard: A hierarchical driver contributes to the same net.
    // §23.6: the hierarchical driver targets the same generated net.
    check_real_net(
        r#"
module top;
  if (1) begin : G
    rn n;
    assign n = 0.5;
  end
  assign G.n = 10.0;
  initial #1 $display("n=%0.2f", G.n);
endmodule
"#,
        "n=10.50",
    );
}

#[test]
fn generate_in_child_instance() {
    // guard: A child instance resolves its generated net.
    check_real_net(
        r#"
module child;
  if (1) begin : G
    rn n;
    assign n = 0.5;
    assign n = 10.0;
  end
endmodule
module top;
  child u();
  initial #1 $display("n=%0.2f", u.G.n);
endmodule
"#,
        "n=10.50",
    );
}

#[test]
fn module_net_and_generated_single_driver() {
    // guard: A module-level net and a generated single-driver net resolve.
    check_real_net(
        r#"
module top;
  rn m;
  assign m = 0.5;
  assign m = 10.0;
  if (1) begin : G
    rn n;
    assign n = 1.25;
  end
  initial #1 $display("m=%0.2f n=%0.2f", m, G.n);
endmodule
"#,
        "m=10.50 n=1.25",
    );
}

#[test]
fn generated_wire_and_unresolved_net() {
    // guard: Built-in wire resolution and an unresolved single-driver net.
    // §6.6.1, Table 6-2: opposing equal-strength wire drivers resolve to X.
    // §6.6.7: an unresolved nettype allows one driver.
    check(
        r#"
nettype real un;
module top;
  if (1) begin : G
    wire w;
    assign w = 1'b0;
    assign w = 1'b1;
    un n;
    assign n = 1.25;
  end
  initial #1 $display("w=%b n=%0.2f", G.w, G.n);
endmodule
"#,
        "w=x n=1.25",
    );
}

#[test]
fn generated_typedef_shadows_package_nettype() {
    // guard: A generated typedef can shadow a package nettype.
    // §6.5, §26.3: the generated typedef defines a variable with one driver.
    check(
        r#"
package p;
  nettype real T;
endpackage
module top;
  import p::*;
  T package_net;
  assign package_net = 2.5;
  if (1) begin : G
    typedef real T;
    T n;
    assign n = 1.25;
  end
  initial #1 $display("net=%0.2f var=%0.2f", package_net, G.n);
endmodule
"#,
        "net=2.50 var=1.25",
    );
}

#[test]
fn generated_real_expression_drivers_and_readers() {
    // §6.6.7 and §11.4.3: both real expressions contribute to the resolved sum.
    // The outside reader, event-controlled reader and child input see that sum.
    // §4.7 and §6.7.3: change a driver after the event control is waiting.
    check_real_net(
        r#"
module reader(input var real n, output real doubled);
  assign doubled = n * 2.0;
endmodule
module top;
  int iv = -2;
  real rv = 2.0;
  real outside, comb_out, child_out;
  if (1) begin : G
    rn n;
    real doubled, event_out;
    assign n = $itor(iv);
    assign n = rv * 1.25;
    assign doubled = n * 2.0;
    always @(n) event_out = n * 2.0;
  end
  assign outside = G.n * 2.0;
  always_comb comb_out = G.n + 1.0;
  reader u(G.n, child_out);
  initial #1 rv = 4.0;
  initial #2 $display("%0.2f %0.2f %0.2f %0.2f %0.2f %0.2f",
                      G.n, G.doubled, G.event_out, outside, comb_out, child_out);
endmodule
"#,
        "3.00 6.00 6.00 6.00 4.00 6.00",
    );
}

#[test]
fn generated_real_delayed_drivers() {
    // §10.3.3: each continuous driver's delay precedes nettype resolution.
    let src = format!(
        "{REAL_SUM}{}",
        r#"
module top;
  real result;
  if (1) begin : G
    rn n;
    assign #2 n = 0.5;
    assign #4 n = 10.0;
  end
  assign result = G.n * 2.0;
  initial begin
    #1 $display("%0.2f", result);
    #2 $display("%0.2f", result);
    #2 $display("%0.2f", result);
  end
endmodule
"#
    );
    let result = xezim::simulate(&src, 10).expect("simulate");
    let messages: Vec<_> = result.output.iter().map(|o| o.message.as_str()).collect();
    assert_eq!(messages, ["0.00", "1.00", "21.00"]);
}

#[test]
fn generated_nettype_declaration_driver() {
    // §6.7.3 and §10.3.1: the net's declaration assignment is a driver.
    check_real_net(
        r#"
module top;
  if (1) begin : G
    rn n = 0.5;
    assign n = 10.0;
  end
  initial #1 $display("n=%0.2f", G.n);
endmodule
"#,
        "n=10.50",
    );
}

fn check_error(src: &str, expected: &str) {
    let error = match xezim::simulate(src, 10) {
        Ok(_) => panic!("expected elaboration to fail"),
        Err(error) => error,
    };
    assert!(error.to_string().contains(expected), "{error}");
}

#[test]
fn generated_variables_still_reject_two_continuous_drivers() {
    // Guard: §6.5 permits one continuous driver on each variable.
    // §23.9 and §26.5 bind these type names to the local variable types.
    for (header, declarations, data_type) in [
        ("", "", "real"),
        ("", "typedef logic [3:0] rn;", "rn"),
        ("", "typedef real rn;", "rn"),
        ("#(parameter type rn = real)", "", "rn"),
    ] {
        let src = format!(
            r#"{REAL_SUM}
module top {header};
  {declarations}
  if (1) begin : G
    {data_type} v;
    assign v = 1;
    assign v = 2;
  end
endmodule
"#
        );
        check_error(&src, "Variable 'G.v' has multiple continuous drivers");
    }
    check_error(
        r#"
package p;
  nettype real T;
endpackage
module top;
  import p::*;
  if (1) begin : G
    typedef real T;
    T v;
    assign v = 1.0;
    assign v = 2.0;
  end
endmodule
"#,
        "Variable 'G.v' has multiple continuous drivers",
    );
}

#[test]
fn generated_unresolved_net_rejects_two_continuous_drivers() {
    // Guard: §6.6.7 requires a resolver for multiple drivers.
    check_error(
        r#"
nettype real un;
module top;
  if (1) begin : G
    un n;
    assign n = 1.0;
    assign n = 2.0;
  end
endmodule
"#,
        "net 'G.n' of an unresolved nettype has 2 continuous drivers",
    );
}

#[test]
fn generated_net_rejects_a_procedural_driver() {
    // Guard: §6.5 prohibits procedural assignments to nets.
    for second_driver in ["", "assign n = 2.0;"] {
        let src = format!(
            r#"{REAL_SUM}
module top;
  if (1) begin : G
    rn n;
    assign n = 1.0;
    {second_driver}
    initial #2 n = 3.0;
  end
endmodule
"#
        );
        check_error(&src, "Net 'G.n' is the target of a procedural assignment");
    }
}

#[test]
fn generated_type_parameter_variable_allows_bit_zero_select() {
    // Guard against classifying the shadowing type parameter as real (§6.20.3, §26.5).
    // Bit 0 of 4'd2 is 0. Bit 1 still reads 0 instead of 1 (§11.5.1).
    check_real_net(
        r#"
module top #(parameter type rn = logic [3:0]);
  if (1) begin : G
    rn v;
    assign v = 4'd2;
  end
  initial #1 $display("low=%b", G.v[0]);
endmodule
"#,
        "low=0",
    );
}
