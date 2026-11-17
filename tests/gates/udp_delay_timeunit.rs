//! IEEE 1800-2023 §28.16 / §29.8 / §3.14.1–§3.14.2: UDP instance
//! delays use the enclosing definition's time unit and precision. The
//! fixtures sample away from stimulus and propagation times (§4.7).
//! Regression: fails on main even with --no-cache (scalar, rounding,
//! array/sequential, constant expressions, module-timescale and scaled wide integers).
//! Default, library, nested-module, disjoint-driver, identity-scale wide-integer and
//! constant-fallback checks pass on main and guard existing behavior.

use std::process::Command;
use std::sync::atomic::{AtomicUsize, Ordering};

fn lines(src: &str) -> Vec<String> {
    let sim = xezim::simulate(src, 100_000).expect("legal UDP delay design");
    sim.output
        .iter()
        .map(|o| o.message.clone())
        .filter(|s| s.starts_with("U|"))
        .collect()
}

#[test]
fn scalar_delays_use_module_units_and_keep_other_drivers() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/module_unit.sv")),
        [
            "U|early 00 00000111",
            "U|real-before 0",
            "U|real-after 1",
            "U|rise 10 11111",
            "U|assign 11",
            "U|fall-before 11 1",
            "U|fall-pair 01 1",
            "U|fall-after 00 0",
            "U|x-before 0",
            "U|x-after x",
        ]
    );
}

#[test]
fn scaled_udp_delay_preserves_an_earlier_disjoint_driver() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/disjoint_drivers.sv")),
        ["U|disjoint q=00 g=0"]
    );
}

#[test]
fn real_parameters_round_in_each_childs_time_scope() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/rounding_scope.sv")),
        [
            "U|round-before 000 000",
            "U|round-first 111 010",
            "U|round-second-before 010",
            "U|round-second-after 111",
        ]
    );
}

#[test]
fn array_and_sequential_instances_use_scaled_delays() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/arrays_sequential.sv")),
        [
            "U|array-before 00 0",
            "U|array-after 11 1",
            "U|hold 00 1",
            "U|seq-before 1",
            "U|seq-after 0",
        ]
    );
}

#[test]
fn default_and_equal_unit_precision_keep_integer_delays() {
    let src = include_str!("udp_delay_timeunit/default_unit.sv");
    let expected = ["U|default-before 0", "U|default-after 1"];
    assert_eq!(lines(src), expected);
    assert_eq!(lines(&format!("`timescale 1ns/1ns\n{src}")), expected);
}

#[test]
fn module_timescale_option_applies_to_udp_delays() {
    static NEXT: AtomicUsize = AtomicUsize::new(0);
    let dir = std::env::temp_dir().join(format!(
        "xezim_udp_delay_timeunit_{}_{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed)
    ));
    std::fs::create_dir_all(&dir).unwrap();
    let src = dir.join("design.sv");
    std::fs::write(&src, include_str!("udp_delay_timeunit/default_unit.sv")).unwrap();
    let output = Command::new(env!("CARGO_BIN_EXE_xezim"))
        .current_dir(&dir)
        .args(["--no-cache", "--module-timescale", "top=10ns/1ns"])
        .arg(&src)
        .output()
        .unwrap();
    assert!(output.status.success(), "{:?}", output);
    let stdout = String::from_utf8(output.stdout).unwrap();
    let got: Vec<_> = stdout.lines().filter(|s| s.starts_with("U|")).collect();
    assert_eq!(got, ["U|default-before 0", "U|default-after 1"]);
    std::fs::remove_dir_all(dir).unwrap();
}

#[test]
fn nested_modules_keep_gate_delay_units() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/nested_module.sv")),
        ["U|nested-before 00", "U|nested-after 11"]
    );
}

#[test]
fn unknown_and_variable_delays_keep_existing_fallbacks() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/constant_fallback.sv")),
        [
            "U|fallback-rise 1 0",
            "U|fallback-fall 0 1",
            "U|fallback-after 0 0"
        ]
    );
}

#[test]
fn library_cells_keep_gate_delay_units() {
    static NEXT: AtomicUsize = AtomicUsize::new(0);
    let dir = std::env::temp_dir().join(format!(
        "xezim_udp_library_{}_{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed)
    ));
    std::fs::create_dir_all(&dir).unwrap();
    let src = dir.join("top.sv");
    let cell = dir.join("cells.v");
    std::fs::write(&src, include_str!("udp_delay_timeunit/library_top.sv")).unwrap();
    std::fs::write(&cell, include_str!("udp_delay_timeunit/library_cells.v")).unwrap();
    let output = Command::new(env!("CARGO_BIN_EXE_xezim"))
        .current_dir(&dir)
        .arg("--no-cache")
        .arg(&src)
        .arg("-v")
        .arg(&cell)
        .output()
        .unwrap();
    assert!(output.status.success(), "{:?}", output);
    let stdout = String::from_utf8(output.stdout).unwrap();
    let got: Vec<_> = stdout.lines().filter(|s| s.starts_with("U|")).collect();
    assert_eq!(got, ["U|library-before 00", "U|library-after 11"]);
    std::fs::remove_dir_all(dir).unwrap();
}

#[test]
fn qualified_constants_keep_numeric_delay_values() {
    assert_eq!(
        lines(include_str!("udp_delay_timeunit/constant_expressions.sv")),
        ["U|constants-before 00000 0", "U|constants-after 11111 1"]
    );
}

#[test]
fn integer_delays_keep_wide_values_exact() {
    // §5.7.1 / §3.14.2: integral time values remain exact when scaled to ticks.
    std::thread::Builder::new()
        .stack_size(64 * 1024 * 1024)
        .spawn(|| {
            for (scope, expected) in [
                ("1ns/1ns", 9_007_199_254_740_993),
                ("1ns/1ps", 9_007_199_254_740_993_000),
            ] {
                let src = include_str!("udp_delay_timeunit/wide_integer.sv")
                    .replace("`timescale 1ns/1ns", &format!("`timescale {scope}"));
                let (_, elab) =
                    xezim_core::parse_and_elaborate_multi(&[src], Some("top"), &[], &[], &[])
                        .expect("legal wide integral delays");
                assert_eq!(elab.udp_instances.len(), 2);
                for instance in &elab.udp_instances {
                    assert_eq!(instance.delay, expected);
                }
            }
        })
        .unwrap()
        .join()
        .unwrap();
}
