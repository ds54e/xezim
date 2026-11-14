//! IEEE 1800-2023 §23.9 and §26.3: a module's fixed unpacked array and
//! a same-named package array are separate objects. Expected values follow
//! declaration scope, §7.4 element selection and §6.8 initialization.

fn check(source: &str, expected: usize) {
    let result = xezim::simulate(source, 1_000).expect("simulation failed");
    let output: Vec<_> = result.output.iter().map(|o| o.message.as_str()).collect();
    assert!(
        output.iter().all(|line| !line.starts_with("FAIL")),
        "{output:?}"
    );
    assert_eq!(
        output
            .iter()
            .filter(|line| line.starts_with("PASS"))
            .count(),
        expected,
        "{output:?}"
    );
}

#[test]
fn local_arrays_own_cells_across_processes_and_shapes() {
    check(include_str!("package_array_storage/local.sv"), 27);
}

#[test]
fn package_arrays_own_cells_in_subroutines_and_methods() {
    check(include_str!("package_array_storage/packages.sv"), 12);
}

#[test]
fn local_array_displaces_wildcard_import() {
    check(include_str!("package_array_storage/shadow.sv"), 6);
}

#[test]
fn explicit_import_uses_its_package_array() {
    check(include_str!("package_array_storage/explicit.sv"), 3);
}

#[test]
fn array_storage_keeps_its_element_type_and_bounds() {
    check(include_str!("package_array_storage/types.sv"), 7);
}

#[test]
fn user_nettypes_keep_their_driver_path() {
    check(include_str!("package_array_storage/nettype_guard.sv"), 2);
}

#[test]
fn dynamic_arrays_and_queues_keep_their_existing_path() {
    check(
        include_str!("package_array_storage/collection_guards.sv"),
        3,
    );
}

#[test]
fn qualified_array_dependencies_and_force_use_owned_cells() {
    check(include_str!("package_array_storage/dependencies.sv"), 9);
}

#[test]
fn instance_named_like_package_keeps_its_array_dependency() {
    check(include_str!("package_array_storage/instance_guard.sv"), 1);
}

#[test]
fn packed_element_subselects_keep_their_declared_shape() {
    check(include_str!("package_array_storage/packed_guard.sv"), 2);
}

#[test]
fn selected_members() {
    check(include_str!("package_array_storage/selected_members.sv"), 3);
}

#[test]
fn qualified_methods() {
    check(
        include_str!("package_array_storage/qualified_methods.sv"),
        5,
    );
}

#[test]
fn variable_negative_labels() {
    check(
        include_str!("package_array_storage/variable_negative_labels.sv"),
        3,
    );
}

#[test]
fn qualified_ports() {
    check(include_str!("package_array_storage/qualified_ports.sv"), 1);
}

#[test]
fn package_owned_bodies() {
    check(
        include_str!("package_array_storage/package_owned_bodies.sv"),
        3,
    );
}

#[test]
fn qualified_consumers() {
    check(
        include_str!("package_array_storage/qualified_consumers.sv"),
        2,
    );
}

#[test]
fn reductions() {
    check(include_str!("package_array_storage/reductions.sv"), 2);
}

#[test]
fn array_methods() {
    check(include_str!("package_array_storage/array_methods.sv"), 1);
}

#[test]
fn package_initializers_and_parenless_methods_keep_their_owner() {
    check(include_str!("package_array_storage/owner_contexts.sv"), 3);
}

#[test]
fn deep_members_keep_package_storage() {
    check(include_str!("package_array_storage/deep_members.sv"), 1);
}

#[test]
fn inherited_properties_shadow_package_arrays() {
    check(include_str!("package_array_storage/inherited_owner.sv"), 1);
}

#[test]
fn array_and_scalar_initializers_keep_their_package() {
    check(
        include_str!("package_array_storage/initializer_owners.sv"),
        1,
    );
}

#[test]
fn module_subroutines_shadow_package_subroutines() {
    check(
        include_str!("package_array_storage/subroutine_shadows.sv"),
        1,
    );
}

#[test]
fn final_blocks_and_class_expressions_keep_their_owner() {
    check(include_str!("package_array_storage/late_owners.sv"), 2);
}

#[test]
fn signed_labels_keep_their_owner_at_every_dimension() {
    check(include_str!("package_array_storage/signed_deep_selects.sv"), 1);
}
