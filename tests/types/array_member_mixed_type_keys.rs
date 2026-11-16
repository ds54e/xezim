//! IEEE 1800-2023 §10.9.1: the last matching type key supplies the value.
//! A typedef renaming integer matches integer (§6.22.1); realtime and real
//! are synonymous (§6.12). Both values already work on the original path.
#[test]
fn later_typedef_key_preserves_last_matching_value() {
    let sim = xezim::simulate(include_str!("array_member_mixed_typedef_key.sv"), 10_000)
        .expect("legal mixed typedef pattern");
    assert!(
        sim.output
            .iter()
            .any(|line| line.message == "T|mixed typedef 99 99")
    );
}

#[test]
fn later_realtime_key_preserves_last_matching_value() {
    let sim = xezim::simulate(include_str!("array_member_mixed_realtime_key.sv"), 10_000)
        .expect("legal mixed realtime pattern");
    assert!(
        sim.output
            .iter()
            .any(|line| line.message == "T|mixed realtime 9.0 9.0")
    );
}
