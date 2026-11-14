//! IEEE 1800-2023 §§6.11.3, 7.2.1, 11.8.1–11.8.4: a packed
//! member keeps its declared sign before widening. Its container's sign
//! does not apply; explicit bit/part selects and concatenations are unsigned.
//! Multiple continuous reads also guard unsigned loads after a signed load
//! when native combinational blocks merge and reuse temporary registers.

use xezim::simulate;

fn check(src: &str, count: usize) {
    let sim = simulate(src, 10_000).expect("simulate");
    let checks: Vec<_> = sim
        .output
        .iter()
        .map(|o| o.message.trim())
        .filter(|s| s.starts_with("PASS ") || s.starts_with("FAIL "))
        .collect();
    assert_eq!(checks.len(), count, "{checks:?}");
    assert!(checks.iter().all(|s| s.starts_with("PASS ")), "{checks:?}");
}

#[test]
fn declared_sign_on_dotted_and_direct_member_loads() {
    check(include_str!("signed_packed_member_read.sv"), 19);
}

#[test]
fn signed_members_in_expressions_preserve_unsigned_neighbours() {
    check(include_str!("signed_packed_member_contexts.sv"), 24);
}

#[test]
fn wide_signed_member_and_unsigned_part_select() {
    check(include_str!("signed_packed_member_wide.sv"), 4);
}

/// §11.6, §11.8.3–§11.8.4: a four-state sign bit repeats into a
/// wider assignment context, including a direct unpacked-element member.
#[test]
fn unknown_member_sign_bits_preserve_four_state_extension() {
    check(include_str!("signed_packed_member_unknown.sv"), 10);
}
