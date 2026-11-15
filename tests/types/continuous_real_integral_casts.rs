//! IEEE 1800-2023 §6.24.1 / §6.12.1: a real-to-integral cast converts
//! numerically even when its target has the same 64-bit width as a real.
use xezim::simulate;

#[test]
fn continuous_real_integral_casts() {
    check(
        include_str!("continuous_real_integral_casts.sv"),
        &[
            "T|r 0000000000000003 0000000000000003 0000000000000003 0000000000000003 00000003 0003 03 00000003 0000000000000003",
            "T|sr fffffffffffffffd fffffffffffffffd fffffffffffffffd fffffffffffffffd fffffffd fffd fd fffffffd fffffffffffffffd",
            "T|sites 0000000000000003 0000000000000003 0000000000000003 0000000000000003 0000000000000003",
            "T|constant 000009184e72a000 0000000000000003 000009184e72a000 000009184e72a000",
            "T|bits 4004000000000000 00000002",
            "T|r fffffffffffffffd fffffffffffffffd fffffffffffffffd fffffffffffffffd fffffffd fffd fd fffffffd fffffffffffffffd",
            "T|sr 0000000000000003 0000000000000003 0000000000000003 0000000000000003 00000003 0003 03 00000003 0000000000000003",
            "T|sites fffffffffffffffd fffffffffffffffd fffffffffffffffd fffffffffffffffd fffffffffffffffd",
            "T|bits c004000000000000 fffffffe",
        ],
    );
}

fn check(src: &str, expected: &[&str]) {
    let sim = simulate(src, 10_000).expect("simulate cast neighbors");
    let lines: Vec<_> = sim
        .output
        .iter()
        .map(|o| o.message.as_str())
        .filter(|s| s.starts_with("T|"))
        .collect();
    assert_eq!(lines, expected);
}

#[test]
fn continuous_real_cast_ranges() {
    check(
        include_str!("continuous_real_cast_ranges.sv"),
        &[
            "T|round 0000000000000001 0000000000000001 0000000000000001",
            "T|round ffffffffffffffff ffffffffffffffff ffffffffffffffff",
            "T|round 0000000000000002 0000000000000002 0000000000000002",
            "T|round fffffffffffffffd fffffffffffffffd fffffffffffffffd",
            "T|large 0020000000000002 0020000000000002 0020000000000002 0020000000000002",
            "T|large ffdffffffffffffe ffdffffffffffffe ffdffffffffffffe",
            "T|unsigned 8000000000000800 8000000000000800 8000000000000800",
        ],
    );
}

#[test]
fn continuous_real_cast_guards() {
    check(
        include_str!("continuous_real_cast_guards.sv"),
        &[
            "T|integral 000123456789abcd 000123456789abcd xz0123456789abcd xz0123456789abcd xz0123456789abcd ffffffffffffffff ffffffffffffffff fedcba9876543210",
            "T|real 0000000000000003 4004000000000000 4004000000000000 4004000000000000",
            "T|context 00000000000000000000000000000003 00000003",
            "T|signed fffffffffffffff0 fffffffffffffff0 fffffffffffffff0 fffffffffffffff0 fffffffffffffff0 0fffffffffffffff",
            "T|real fffffffffffffffd c004000000000000 c004000000000000 c004000000000000",
            "T|context fffffffffffffffffffffffffffffffd fffffffd",
            "T|context 00000000000000000000000000000000 00000000",
        ],
    );
}
