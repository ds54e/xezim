//! IEEE 1800-2023 §6.24.1 / §6.12.1 / §20.5: a named integral
//! cast rounds before conversion functions consume it, including dimensions.

fn check(src: &str, expected: &[&str]) {
    let sim = xezim::simulate(src, 100_000).expect("simulate named real casts");
    let lines: Vec<_> = sim
        .output
        .iter()
        .map(|o| o.message.trim())
        .filter(|s| s.starts_with("PASS") || s.starts_with("FAIL"))
        .collect();
    assert_eq!(lines, expected);
}

#[test]
fn named_integral_casts_round_before_constant_real_functions() {
    check(
        include_str!("constant_named_real_cast.sv"),
        &[
            "PASS int",
            "PASS byte",
            "PASS shortint",
            "PASS longint",
            "PASS integer",
            "PASS alias",
            "PASS package",
            "PASS unsigned_vector",
            "PASS signed_vector",
            "PASS unsigned_atom",
            "PASS negative",
            "PASS narrowed",
            "PASS parameter",
            "PASS packed",
            "PASS unpacked",
            "PASS replication",
            "PASS bits",
            "PASS sum",
            "PASS nested",
            "PASS procedural_constant",
            "PASS procedural",
            "PASS ceil",
            "PASS floor",
            "PASS sqrt",
            "PASS ln",
            "PASS itor_cast",
            "PASS real_guards",
            "PASS builtin_guards",
            "PASS rounding_guards",
            "PASS integral_guard",
        ],
    );
}

#[test]
fn named_integral_cast_in_a_constant_part_select_width() {
    check(
        include_str!("constant_named_real_cast_select.sv"),
        &["PASS select"],
    );
}

#[test]
fn named_cast_admission_keeps_constant_function_fallbacks() {
    check(
        include_str!("constant_named_real_cast_fallback.sv"),
        &[
            "PASS literal_fallback",
            "PASS array_fallback",
            "PASS string_fallback",
            "PASS host_fallback",
            "PASS computed_fallback",
            "PASS bound_fallback",
            "PASS existing_call",
        ],
    );
}
