//! IEEE 1800-2023 §11.8.1/§11.8.2: every unsigned operand supplies
//! the context type before a signed neighbour widens. §6.24.1 casts,
//! §7.2/§7.3 members, §13.4 calls, §23 hierarchy and §25/§26 scopes.
#[test]
fn unsigned_operand_kinds() {
    let out = xezim::simulate(include_str!("unsigned_operand_kinds.sv"), 10)
        .unwrap()
        .output
        .iter()
        .map(|o| o.message.clone())
        .collect::<Vec<_>>();
    for expected in [
        "union_function=000000000000017f",
        "proc_choice=00000000000000ff",
        "fn_sum=000000000000017f",
        "pkg_left=000000000000017f",
        "pkg_right=000000000000017f",
        "pkg_signed=ffffffffffffff7f",
        "pkg_unsigned=000000000000017f",
        "pkg_concat=000000000000017f",
        "pkg_narrow=7f",
        "pkg_choice=00000000000000ff",
        "call_left=000000000000017f",
        "call_right=000000000000017f",
        "call_signed=ffffffffffffff7f",
        "call_unsigned=000000000000017f",
        "call_concat=000000000000017f",
        "call_narrow=7f",
        "call_choice=00000000000000ff",
        "unp_left=000000000000017f",
        "unp_right=000000000000017f",
        "unp_signed=ffffffffffffff7f",
        "unp_unsigned=000000000000017f",
        "unp_concat=000000000000017f",
        "unp_narrow=7f",
        "unp_choice=00000000000000ff",
        "union_left=000000000000017f",
        "union_right=000000000000017f",
        "union_signed=ffffffffffffff7f",
        "union_unsigned=000000000000017f",
        "union_concat=000000000000017f",
        "union_narrow=7f",
        "union_choice=00000000000000ff",
        "cast_left=000000000000017f",
        "cast_right=000000000000017f",
        "cast_signed=ffffffffffffff7f",
        "cast_unsigned=000000000000017f",
        "cast_concat=000000000000017f",
        "cast_narrow=7f",
        "cast_choice=00000000000000ff",
        "iface_left=000000000000017f",
        "iface_right=000000000000017f",
        "iface_signed=ffffffffffffff7f",
        "iface_unsigned=000000000000017f",
        "iface_concat=000000000000017f",
        "iface_narrow=7f",
        "iface_choice=00000000000000ff",
        "hier_left=000000000000017f",
        "hier_right=000000000000017f",
        "hier_signed=ffffffffffffff7f",
        "hier_unsigned=000000000000017f",
        "hier_concat=000000000000017f",
        "hier_narrow=7f",
        "hier_choice=00000000000000ff",
    ] {
        assert!(
            out.iter().any(|line| line.trim() == expected),
            "missing {expected}: {out:?}"
        );
    }
}
