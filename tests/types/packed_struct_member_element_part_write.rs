//! IEEE 1800-2023 §5.7.1, §6.6, §6.11.2, §7.2.1, §7.4.1,
//! §7.4.2, §10.3, §10.4.1, §10.4.2, §10.8, §11.5.1, §11.8.3,
//! §23.9 and §26.3: part-select writes fit the RHS to the selected bits
//! of a packed member element and preserve adjacent elements and fields.

use std::process::Command;

const SRC: &str = include_str!("packed_struct_member_element_part_write.sv");

fn run(source: &str, env: &[(&str, &str)]) -> String {
    let tmp = Command::new("mktemp")
        .arg("-d")
        .arg(std::env::temp_dir().join("packed_member_part_write.XXXXXX"))
        .output()
        .expect("create temporary directory");
    assert!(tmp.status.success());
    let dir = std::path::PathBuf::from(String::from_utf8(tmp.stdout).unwrap().trim());
    let src = dir.join("top.sv");
    std::fs::write(&src, source).unwrap();
    let output = Command::new(env!("CARGO_BIN_EXE_xezim"))
        .arg("--no-cache")
        .args(["-s", "top"])
        .arg(&src)
        .current_dir(&dir)
        .env_remove("XEZIM_METHOD_TIER")
        .env_remove("XEZIM_COMPILE_METHODS")
        .env_remove("XEZIM_METHOD_CACHE")
        .envs(env.iter().copied())
        .output()
        .expect("run xezim");
    std::fs::remove_dir_all(&dir).unwrap();
    let text = format!(
        "{}{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    assert!(output.status.success(), "{text}");
    text
}

fn check(env: &[(&str, &str)]) {
    let text = run(SRC, env);
    for name in [
        "mixed two state field",
        "mixed four state guard",
        "signed narrow rhs",
        "unbased fill rhs",
        "constant",
        "whole element read write",
        "preserve field and lane",
        "indexed up variable",
        "indexed down variable",
        "single bit",
        "two outer indices",
        "three outer indices",
        "two member indices",
        "nested packed members",
        "three nested packed members",
        "unpacked array",
        "unpacked neighbor",
        "plain struct",
        "four state",
        "partial high",
        "partial low",
        "outside slice",
        "unknown slice",
        "neighbor preserved after clipping",
        "function local",
        "nonblocking",
        "continuous",
        "continuous update",
    ] {
        assert!(text.lines().any(|l| l == format!("PASS {name}")), "{text}");
    }
    assert!(
        text.contains("ALL PASS") && !text.contains("FAIL"),
        "{text}"
    );
}

#[test]
fn packed_member_element_part_writes() {
    check(&[]);
}

#[test]
fn packed_member_element_part_writes_interpreted() {
    check(&[("XEZIM_COMPILE_METHODS", "0")]);
}

#[test]
fn packed_member_element_part_writes_eager_methods() {
    check(&[("XEZIM_METHOD_TIER", "0")]);
}

/// §11.5.1: invalid addresses leave the aggregate intact; whole-element and
/// independent bit writes are controls that already pass before this fix.
#[test]
fn packed_member_element_part_write_guards() {
    let text = run(
        include_str!("packed_struct_member_element_part_write_guards.sv"),
        &[],
    );
    for name in [
        "independent bit",
        "whole element and field",
        "outside root",
        "outside member",
        "unknown root",
        "unknown member",
        "outside selected byte",
        "unknown selected byte",
        "wide index",
        "wide slice base",
        "unsigned index overflow",
        "supply zero",
        "supply one",
    ] {
        assert!(text.lines().any(|l| l == format!("PASS {name}")), "{text}");
    }
    assert!(
        text.contains("ALL PASS") && !text.contains("FAIL"),
        "{text}"
    );
}

/// §23.9/§26.3: a qualified package variable is separate from a module
/// variable of the same name, even when child scopes reuse that name too.
#[test]
fn packed_member_element_part_write_package_shadow_guard() {
    let text = run(
        include_str!("packed_struct_member_element_part_write_package_guard.sv"),
        &[],
    );
    assert!(
        text.lines().any(|l| l.starts_with("CONTEXT ")
            && l.contains("child=28 interface=28 ")
            && l.ends_with(" parent=00000000")),
        "{text}"
    );
}

/// §7.2.1/§7.4.1/§11.5.1 and §10.4.1/§10.4.2: repeated instance
/// names do not alias storage; selectors run once before their write.
#[test]
fn packed_member_element_part_write_indices_and_instances() {
    let text = run(
        include_str!("packed_struct_member_element_part_write_indices.sv"),
        &[],
    );
    assert!(
        text.contains("ALL PASS") && !text.contains("FAIL"),
        "{text}"
    );
}
