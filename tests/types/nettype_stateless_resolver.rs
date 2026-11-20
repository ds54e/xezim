//! IEEE 1800-2023 §6.6.7 permits a resolver that preserves no state and
//! has no side effects. §13.4.2 defines default static lifetime and both
//! explicit and inherited automatic lifetime.

const SUM_BODY: &str = r#"
    res = 0.0;
    foreach (d[k]) res += d[k];
"#;

const NET_AND_DRIVERS: &str = r#"
  nettype real rn with res;
  rn n;
  real driver;
  assign n = 1.25;
  assign n = driver;
  initial begin
    driver = 2.0;
    #1 $display("n=%0.2f", n);
    #1 driver = 2.75;
    #1 $display("n=%0.2f", n);
  end
endmodule
"#;

fn check_resolution(source: &str) {
    let sim = xezim::simulate(source, 10_000).expect("simulate resolved net");
    let lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    // §6.6.7: each driver change triggers resolution using the current values.
    assert_eq!(lines, ["n=3.25", "n=4.00"]);
}

fn check_module(module_lifetime: &str, function_lifetime: &str, body: &str) {
    check_resolution(&format!(
        r#"`timescale 1ns/1ps
module {module_lifetime}top;
  function {function_lifetime}real res(input real d[]);
{body}
  endfunction
{NET_AND_DRIVERS}"#
    ));
}

fn check_package(package_lifetime: &str) {
    check_resolution(&format!(
        r#"`timescale 1ns/1ps
package {package_lifetime}rp;
  function real res(input real d[]);
{SUM_BODY}
  endfunction
endpackage
import rp::*;
module top;
{NET_AND_DRIVERS}"#
    ));
}

#[test]
fn module_static_by_default() {
    check_module("", "", SUM_BODY);
}

#[test]
fn package_static_by_default() {
    check_package("");
}

#[test]
fn explicit_static_with_reset_local() {
    check_module(
        "",
        "static ",
        r#"
    real total;
    total = 0.0;
    foreach (d[k]) total += d[k];
    return total;
"#,
    );
}

#[test]
fn explicit_automatic() {
    check_module("", "automatic ", SUM_BODY);
}

#[test]
fn automatic_from_module() {
    check_module("automatic ", "", SUM_BODY);
}

#[test]
fn automatic_from_package() {
    check_package("automatic ");
}
