//! IEEE 1800-2023 §10.9.1/§10.9.2: index/member keys take precedence
//! over the last matching type key, then default. Resolved nettype
//! drivers (§6.6.7) and procedural assignments use the same element types.
fn check(src: &str, expected: &[&str]) {
    let sim = xezim::simulate(src, 10_000).expect("legal array-member type keys");
    let lines: Vec<_> = sim
        .output
        .iter()
        .map(|line| line.message.as_str())
        .filter(|line| line.starts_with("T|"))
        .collect();
    assert_eq!(lines, expected);
}

#[test]
fn resolved_and_variable_array_member_type_keys() {
    check(
        include_str!("array_member_type_keys.sv"),
        &[
            "T|integer 7 8 7 int 9 9 byte 10 10",
            "T|typedef 11 11 vector 12 12 packed aa aa",
            "T|nested 13 13 14 15 struct 16 3 17 4",
            "T|plain 7 8 7 unresolved 7 8 7 procedural 7 7 7",
            "T|update 11 12 15 16",
        ],
    );
}

#[test]
fn type_key_precedence_and_replication_guards() {
    check(
        include_str!("array_member_type_key_precedence.sv"),
        &[
            "T|unmatched 99 99 99 8",
            "T|indices 7 8 7 / 7 8 7",
            "T|last type 7 7 7 vectors 7 7",
            "T|replication 7 7 7 80 80",
            "T|states -128 -128 xz100110",
        ],
    );
}

#[test]
fn scoped_typedef_key_keeps_nonmatching_default() {
    check(
        include_str!("array_member_scoped_type_key.sv"),
        &["T|resolved net 99 99", "T|variable 99 99"],
    );
}
