//! IEEE 1800-2023 §19.5, §19.5.1, §19.5.3, §19.5.5–§19.5.7, §19.11.1.
use xezim::simulate;

#[test]
fn real_scalar_bins_cover_numeric_values_and_endpoints() {
    let sim = simulate(include_str!("covergroup_real_bins.sv"), 100_000).unwrap();
    let lines: Vec<_> = sim
        .output
        .iter()
        .map(|o| o.message.trim())
        .filter(|s| s.starts_with("bins "))
        .collect();
    assert_eq!(
        lines,
        [
            "bins 0 0 0 0 0 50 0",
            "bins 50 100 100 100 0 50 0",
            "bins 100 100 100 100 0 100 0",
            "bins 100 100 100 100 100 100 0",
            "bins 100 100 100 100 100 100 100",
        ]
    );
    assert_eq!(sim.error_count, 0);
}

#[test]
fn real_exclusions_and_default_bins() {
    let sim = simulate(include_str!("covergroup_real_exclusions.sv"), 100_000).unwrap();
    let lines: Vec<_> = sim.output.iter().map(|o| o.message.trim()).collect();
    let coverage: Vec<_> = lines
        .iter()
        .copied()
        .filter(|s| s.starts_with("cp ") || s.starts_with("default "))
        .collect();
    assert_eq!(
        coverage,
        [
            "default before 0 0/0",
            "cp 0 0/2, group 0",
            "cp 0 0/2, group 0",
            "cp 50 1/2, group 50",
            "cp 50 1/2, group 50",
            "cp 100 2/2, group 100",
            "default after 0 0/0",
        ]
    );
    assert_eq!(sim.error_count, 1, "{lines:?}");
    assert!(
        lines
            .iter()
            .any(|l| l.contains("Illegal bin hit at value 2.5: cg.cp.bad")),
        "{lines:?}"
    );
}

/// §19.5.1.1, §19.5.2–§19.5.4, §19.5.7: integral value, with,
/// transition, wildcard and automatic bins retain their coverage.
#[test]
fn integral_bins_keep_their_matching_rules() {
    let sim = simulate(include_str!("covergroup_real_bins_integral.sv"), 100_000).unwrap();
    let lines: Vec<_> = sim
        .output
        .iter()
        .map(|o| o.message.trim())
        .filter(|s| s.starts_with("guard "))
        .collect();
    assert_eq!(
        lines,
        ["guard a 50 25 0 0 12.5", "guard b 50 50 100 100 25.0"]
    );
    assert_eq!(sim.error_count, 0);
}
