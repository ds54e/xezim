//! IEEE 1800-2023 §10.3.2, §13.5.1–§13.5.4, §23.9: named and
//! hierarchical struct-array actuals depend on the same member leaves as
//! positional actuals. Samples are separated from writes (§4.7).

fn check(source: &str, expected: &[&str]) {
    let actual: Vec<_> = xezim::simulate(source, 100_000)
        .expect("simulate struct-array actual sensitivity")
        .output
        .iter()
        .map(|o| o.message.trim().to_string())
        .filter(|s| s.starts_with("T|") || s.starts_with("PASS") || s.starts_with("FAIL"))
        .collect();
    assert_eq!(actual, expected);
}

#[test]
fn reported_actual_spellings() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/issue.sv"),
        &["PASS named", "PASS root", "PASS top", "PASS block"],
    );
}

#[test]
fn scoped_member_writes_only_wake_their_readers() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/struct_array_isolation.sv"),
        &[
            "T|top 1 1 1 1 0 0",
            "T|child 1 1 1 1 3 0",
            "T|unrelated 1 1 1 1 3 0",
            "T|sibling 1 1 1 1 3 7",
        ],
    );
}

#[test]
fn const_ref_actuals_keep_their_scope() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/const_ref_isolation.sv"),
        &[
            "T|top 1 1 1 1 0 0",
            "T|child 1 1 1 1 3 0",
            "T|unrelated 1 1 1 1 3 0",
            "T|sibling 1 1 1 1 3 7",
        ],
    );
}

#[test]
fn either_actual_wakes_two_calls() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/two_calls.sv"),
        &["T|a 2", "T|b 6"],
    );
}

#[test]
fn named_selected_members_keep_four_state_values() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/selected_members.sv"),
        &[
            "T|init 12 12 12",
            "T|xz xz xz xz",
            "T|whole fe fe fe",
            "T|index fe fe 80",
        ],
    );
}

#[test]
fn procedural_input_and_reference_actuals() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/procedural_struct_array.sv"),
        &[
            "T|function_i_pos 21",
            "T|task_i 21",
            "T|function_i_named 21",
            "T|task_i 21",
            "T|function_i_root 21",
            "T|task_i 21",
            "T|function_i_top 21",
            "T|task_i 21",
            "T|function_i_block 23",
            "T|task_i 23",
            "T|function_c_pos 21",
            "T|task_c 21",
            "T|function_c_named 21",
            "T|task_c 21",
            "T|function_c_root 21",
            "T|task_c 21",
            "T|function_c_top 21",
            "T|task_c 21",
            "T|function_c_block 23",
            "T|task_c 23",
            "T|function_r_pos 21",
            "T|task_r 21",
            "T|function_r_named 21",
            "T|task_r 21",
            "T|function_r_root 21",
            "T|task_r 21",
            "T|function_r_top 21",
            "T|task_r 21",
            "T|function_r_block 23",
            "T|task_r 23",
            "T|write_pos 31 23",
            "T|write_named 32 23",
            "T|write_root 33 23",
            "T|write_top 34 23",
            "T|write_block 34 35",
        ],
    );
}

#[test]
fn named_scalar_struct_actual() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/isolated_scalar_named.sv"),
        &["T|value 1"],
    );
}

#[test]
fn named_int_array_actual() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/isolated_integer_named.sv"),
        &["T|value 1"],
    );
}

#[test]
fn packed_struct_array_actuals() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/packed_array.sv"),
        &["T|member 1 1 1 1", "T|whole 3 3 3 3"],
    );
}

#[test]
fn default_and_body_reads_remain_dependencies() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/default_and_body.sv"),
        &["T|array 3", "T|default 8", "T|body 21", "T|unrelated 21"],
    );
}

#[test]
fn rooted_actual_bypasses_local_module_name() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/root_shadow.sv"),
        &["T|root 0 1 1", "T|local 3 1 1"],
    );
}

#[test]
fn scalar_calls_keep_existing_scope_path() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/scalar_scope_guard.sv"),
        &[
            "T|0 1 1 1 1",
            "T|1 3 3 3 3",
            "T|2 5 5 5 5",
            "T|3 5 5 5 5",
            "T|4 5 5 5 5",
            "T|5 5 5 5 5",
        ],
    );
}

#[test]
fn selected_generate_instance_and_interface_scopes() {
    check(
        include_str!("struct_array_actual_sensitivity_1110/scope_kinds.sv"),
        &["T|gen 0 1 0 0 0", "T|inst 0 1 0 3 0", "T|iface 0 1 0 3 5"],
    );
}
