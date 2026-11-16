//! IEEE 1800-2023 §9.4.2.3, §16.8, §16.10, §26.3:
//! event filters and nearer variable declarations retain their meaning.
fn check(source: &str, expected: &[&str]) {
    let sim = xezim::simulate(source, 100).unwrap();
    let mut lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    let mut expected = expected.to_vec();
    lines.sort_unstable();
    expected.sort_unstable();
    assert_eq!(lines, expected);
}
#[test]
fn untyped_event_iff() {
    check(
        include_str!("sva_default_untyped_event_iff.sv"),
        &["default=0/0", "untyped=0/0", "PASS"],
    );
}
#[test]
fn signal_hides_imported_sequence() {
    check(
        include_str!("sva_default_signal_shadow.sv"),
        &[
            "signal_named_like_default_seq=2/0",
            "signal_named_like_portless_seq=2/0",
            "signal_named_like_formal_seq=2/0",
        ],
    );
}
#[test]
fn local_hides_sequence() {
    check(
        include_str!("sva_default_local_shadow.sv"),
        &[
            "local_named_like_default_seq=2/0",
            "local_named_like_portless_seq=2/0",
            "formal_named_like_default_seq=2/0",
        ],
    );
}

#[test]
fn untyped_arithmetic_keeps_self_determined_fallback() {
    check(
        include_str!("sva_default_self_determined_fallback.sv"),
        &["self-determined=0/2"],
    );
}

#[test]
fn defaults_use_sampled_package_and_clocking_names() {
    check(
        include_str!("sva_default_sampled_names.sv"),
        &["package=2/0 control=2/0", "clocking=2/0 control=2/0"],
    );
}

#[test]
fn bare_assertion_signal_hides_imported_sequence() {
    check(
        include_str!("sva_default_bare_signal_shadow.sv"),
        &["bare-shadow=0/2"],
    );
}
