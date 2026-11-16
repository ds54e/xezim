//! §14.3, §14.5, §14.13: input edge guards and a constant port actual.
use crate::harness::{Order, check};

#[test]
fn c14_3_clocking_input_explicit_edge() {
    check(
        "14.3_clocking_input_edge_explicit",
        include_str!("sv/14.3_clocking_input_edge_explicit.sv"),
        "top",
        Order::Exact,
        &["T|edge|value=8"],
        &[],
    );
}

#[test]
fn c14_3_clocking_input_default_edge() {
    check(
        "14.3_clocking_input_edge_default",
        include_str!("sv/14.3_clocking_input_edge_default.sv"),
        "top",
        Order::Exact,
        &["T|edge|value=8"],
        &[],
    );
}

#[test]
fn c14_5_clocking_constant_port() {
    check(
        "14.5_clocking_constant_port",
        include_str!("sv/14.5_clocking_constant_port.sv"),
        "top",
        Order::Exact,
        &["T|constant-port|value=5"],
        &[],
    );
}
