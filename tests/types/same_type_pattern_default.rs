//! IEEE 1800-2023 §10.9.2: a default matching a member's self-determined
//! type assigns the whole member. §6.22.1 requires matching types rather
//! than equal widths; unmatched aggregate members recurse. §10.3.2 keeps
//! these continuous assignments responsive to later source changes.

fn lines(src: &str) -> Vec<String> {
    xezim::simulate(src, 100_000)
        .expect("simulate")
        .output
        .iter()
        .map(|line| line.message.trim().to_string())
        .filter(|line| line.starts_with("T|"))
        .collect()
}

/// §10.9.2: the reporter's module-local typedefs, including a leaf type key.
/// `different` and `multidim_different` follow the recursive rule and slang;
/// Verilator 5.020 instead takes these equal-width nonmatching values whole.
#[test]
fn matching_default_sets_packed_members_whole() {
    assert_eq!(
        lines(include_str!("same_type_pattern_default.sv")),
        [
            "T|multidim 7 1 2",
            "T|multidim_different 7 6 6",
            "T|s 7 1 2",
            "T|alias 7 3 4",
            "T|different 7 6 6",
            "T|typed 9 1 2",
            "T|named 18 5 6",
            "T|leaf_key 18 12",
            "T|vector 7 9 a",
            "T|packed_array 7 1 2 3 4",
            "T|enum 7 12",
            "T|many 7 1 2 1 2",
            "T|nested 7 9 1 2",
            "T|array 1 2 1 2",
            "T|update a b a b",
        ]
    );
}

/// §10.9.2: scalar defaults recurse and keys matching the member win.
#[test]
fn nonmatching_defaults_recurse_and_explicit_keys_win() {
    assert_eq!(
        lines(include_str!("same_type_pattern_default_guards.sv")),
        [
            "T|scalar 7 1 1",
            "T|sized 7 2 2",
            "T|param_expr 7 3 3",
            "T|zero 7 0 0",
            "T|ones 7 f f",
            "T|type_key 9 3 4",
            "T|nested_pattern 7 5 5",
        ]
    );
}

/// §10.8: other assignment-like contexts retain their established values.
#[test]
fn assignment_like_contexts_keep_their_values() {
    assert_eq!(
        lines(include_str!("same_type_pattern_default_contexts.sv")),
        [
            "T|proc 3 5 6",
            "T|comb 7 5 6",
            "T|initializer 5 1 2",
            "T|parameter 7 1 2",
            "T|localparam 9 3 4",
            "T|argument 56",
            "T|return 11 5 6",
        ]
    );
}

/// §6.22.1(d), §10.9.2: a hidden typedef is a different declaration,
/// even with an identical body; aliases must not bypass this guard.
#[test]
fn hidden_typedef_defaults_recurse() {
    assert_eq!(
        lines(include_str!("same_type_pattern_default_shadow.sv")),
        [
            "T|hidden 7 66",
            "T|earlier_outer_into_local 7 22",
            "T|identical 7 22"
        ]
    );
}

/// §6.22.1(d): identical text and offsets in different files do not make
/// package typedefs match. Keep the sources separate through parsing.
#[test]
fn separate_files_do_not_share_a_typedef_declaration() {
    let sources = [
        include_str!("same_type_pattern_default_files_1.sv").to_string(),
        include_str!("same_type_pattern_default_files_2.sv").to_string(),
        include_str!("same_type_pattern_default_files_3.sv").to_string(),
    ];
    let sim = xezim::simulate_multi(
        &sources,
        100_000,
        Some("top"),
        &[],
        &[],
        None,
        false,
        None,
        None,
        &[],
        &[],
        None,
        &[],
        0,
        u64::MAX,
        None,
        &[],
        None,
        None,
        None,
        None,
        false,
    )
    .expect("simulate separate source files");
    let output: Vec<_> = sim
        .output
        .iter()
        .map(|line| line.message.trim())
        .filter(|line| line.starts_with("T|"))
        .collect();
    assert_eq!(output, ["T|cross_file 7 2 2"]);
}

/// §6.22.1(h): bare imports and package-qualified aliases name one typedef.
#[test]
fn package_typedef_aliases_match() {
    assert_eq!(
        lines(include_str!("same_type_pattern_default_package.sv")),
        ["T|package_alias 7 12 9 56"]
    );
}

/// §6.20.3, §6.22.1(b,d), §6.6.7, §10.9.2: every writer of a hidden type name
/// must prevent a nonmatching default from being assigned whole.
#[test]
fn type_parameters_and_nettypes_hiding_typedefs_recurse() {
    assert_eq!(
        lines(include_str!("same_type_pattern_default_parameter.sv")),
        [
            "T|typeparam_alias 7 66",
            "T|typeparam_direct 7 66",
            "T|typeparam_ctrl 7 66",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_localparam.sv")),
        [
            "T|lptype_alias 7 66",
            "T|lptype_direct 7 66",
            "T|lptype_ctrl 7 66",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_anonymous.sv")),
        [
            "T|typeparam_anon_alias 7 66",
            "T|typeparam_anon_ctrl 7 66",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_parameter_arrays.sv")),
        [
            "T|unit_alias_into_typeparam_member 7 22",
            "T|typeparam_multidim 7 6 6",
            "T|typeparam_packed_array 7 4444",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_nettype.sv")),
        [
            "T|nettype_hides 7 66",
            "T|nettype_ctrl 7 66",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_generate_parameter.sv")),
        [
            "T|gen_lptype_alias 7 66",
            "T|gen_lptype_direct 7 66",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_package_parameter.sv")),
        [
            "T|typeparam_hides_pkg_type 7 66",
            "T|gen_lptype_hides_module_type 7 66",
        ]
    );
    assert_eq!(
        lines(include_str!("same_type_pattern_default_class_parameter.sv")),
        ["T|class_parameter 7 66"]
    );
}
