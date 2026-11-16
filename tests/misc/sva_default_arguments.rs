//! IEEE 1800-2023 §16.8, §16.8.1, §16.12, §16.12.7, §16.12.18,
//! §16.14.1–§16.14.3:
//! omitted actuals and explicit overrides must execute the corresponding actions.
#[test]
fn sva_default_arguments() {
    let sim = xezim::simulate(include_str!("sva_default_arguments.sv"), 100).unwrap();
    let lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    assert_eq!(
        lines,
        [
            "typed_truncate=0/2",
            "typed_inherit=0/2",
            "omitted=0/2",
            "explicit=0/2",
            "partial=0/2",
            "empty=0/2",
            "named=0/2",
            "named_default=0/2",
            "bare=0/2",
            "override=2/0",
            "typed=2/0",
            "false_default=0/2",
            "typed_override=0/2",
            "nested=2/0",
            "sequence_bare=2/0",
            "sequence_named=0/2",
            "assume_default=0/2",
            "assume_pass=2/0",
            "cover_default=2/0",
            "cover_fail=0/0",
            "scope=2/0",
            "expression=2/0",
            "PASS",
        ]
    );
}

fn check_lines(source: &str, expected: &[&str]) {
    let sim = xezim::simulate(source, 100).unwrap();
    let mut lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    let mut expected = expected.to_vec();
    lines.sort_unstable();
    expected.sort_unstable();
    assert_eq!(lines, expected);
}

/// §16.8/§16.12: defaults follow instance and generate declaration scopes.
#[test]
fn sva_default_scopes() {
    check_lines(
        include_str!("sva_default_scopes.sv"),
        &[
            "child=1/1",
            "interface=1/1",
            "generate0=2",
            "generate1=2",
            "package=2",
            "PASS",
        ],
    );
}

/// §16.5.1/§16.9.3: defaults are live expressions, including sampled functions.
#[test]
fn sva_default_live_expressions() {
    check_lines(
        include_str!("sva_default_context.sv"),
        &[
            "live=1/1 control=1/1 past=2/0 override=0/2",
            "past-control=2/0",
            "PASS",
        ],
    );
}

/// §16.8/§26.3: an importing module cannot change a package default's binding.
#[test]
fn sva_default_package_shadow() {
    check_lines(
        include_str!("sva_default_package_shadow.sv"),
        &["package-shadow=2/0", "PASS"],
    );
}

/// §16.8: preserve the LRM-correct result of the existing array binding path.
#[test]
fn sva_default_array_fallback() {
    check_lines(
        include_str!("sva_default_array_fallback.sv"),
        &["array=2/0 control=2/0", "PASS"],
    );
}

/// §16.8/§9.4.2.3: never substitute only the prefix of an event default.
#[test]
fn sva_default_event_fallback() {
    check_lines(
        include_str!("sva_default_event_iff_fallback.sv"),
        &["event-iff=0/0", "PASS"],
    );
}

/// §5.6.1/§16.8.1: an unrepresented typedef and its inherited type keep
/// the existing path instead of treating their defaults as untyped.
#[test]
fn sva_default_escaped_type_fallback() {
    check_lines(
        include_str!("sva_default_escaped_type_fallback.sv"),
        &["escaped-type=0/2", "PASS"],
    );
}

/// §16.8.1/§16.12.18: preserve the existing typed named-actual result.
#[test]
fn sva_default_named_type_fallback() {
    check_lines(
        include_str!("sva_default_named_type_fallback.sv"),
        &["named-typed=0/2", "PASS"],
    );
}
