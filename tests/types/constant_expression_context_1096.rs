//! IEEE 1800-2023 regression and main-passing guards for upstream #1096.

use std::process::Command;
use std::sync::atomic::{AtomicUsize, Ordering};

static NEXT: AtomicUsize = AtomicUsize::new(0);

struct RunDir(std::path::PathBuf);
impl Drop for RunDir {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

fn check(source: &str, expected: &[&str], no_warnings: bool) {
    let unique = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let dir = RunDir(std::env::temp_dir().join(format!(
        "xezim-1096-{}-{unique}-{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed)
    )));
    std::fs::create_dir(&dir.0).unwrap();
    std::fs::write(dir.0.join("test.sv"), source).unwrap();
    let mut command = Command::new(env!("CARGO_BIN_EXE_xezim"));
    for (key, _) in std::env::vars_os() {
        if key.to_string_lossy().starts_with("XEZIM_") {
            command.env_remove(key);
        }
    }
    let output = command
        .current_dir(&dir.0)
        .args(["--no-cache", "test.sv"])
        .output()
        .expect("run xezim");
    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(output.status.success(), "{stdout}\n{stderr}");
    if no_warnings {
        assert!(!stderr.to_ascii_lowercase().contains("warning"), "{stderr}");
    }
    let lines: Vec<_> = stdout
        .lines()
        .filter(|line| {
            line.starts_with("T|") || line.starts_with("PASS") || line.starts_with("FAIL")
        })
        .collect();
    // Several independent initial blocks may print at the same time. Compare
    // the multiset so the test does not impose an Active-region ordering (§4.7).
    let mut actual = lines;
    let mut expected = expected.to_vec();
    actual.sort_unstable();
    expected.sort_unstable();
    assert_eq!(actual, expected, "{stdout}\n{stderr}");
}

/// §11.8.2: "Propagate the type and size of the expression"; §§6.20.2, 6.8, 10.8, 23.10.1 supply expression/assignment contexts. Thus 18, -6, 6, 6, 49, ffff, ffff.
#[test]
fn constant_expressions_receive_their_context() {
    check(
        include_str!(
            "constant_expression_context_1096/constant_expressions_receive_their_context.sv"
        ),
        &[
            "PASS P=18",
            "PASS L=-6",
            "PASS Q=6",
            "PASS V=6",
            "PASS C=49",
            "PASS PE[1]=ffff",
            "PASS HW=ffff",
        ],
        false,
    );
}

/// §6.16: "A string variable shall not contain the special character" \0; §§6.20.2,10.8 convert the selected de arm to string; §21.2.1.7 formats text.
#[test]
fn keeps_string_override_text() {
    check(
        include_str!("constant_expression_context_1096/keeps_string_override_text.sv"),
        &[
            "T|text [de] [de.txt] 2",
            "T|text [de] [de.txt] 2",
            "T|text [de] [de.txt] 2",
        ],
        false,
    );
}

/// §11.8.2 comparison exception: operands "shall affect each other as if they were context-determined operands"; Table 11-21 makes 3+3+7=13 at 4 bits, so equality to 5 is false (and inequalities true).
#[test]
fn keeps_comparison_operand_context() {
    check(
        include_str!("constant_expression_context_1096/keeps_comparison_operand_context.sv"),
        &["T|branch right", "T|compare 010101 0 0 1 1"],
        false,
    );
}

/// §10.8 explicitly typed parameter assignments are assignment-like; §§11.8.1,11.8.2 propagate 32 unsigned context bits before subtraction/multiplication: 3-5=-2, -1, (-2)*3=-6. §11.8.2: "Propagate the type and size of the expression".
#[test]
fn keeps_typed_declaration_contexts() {
    check(
        include_str!("constant_expression_context_1096/keeps_typed_declaration_contexts.sv"),
        &["T|generated -2 -1 -6", "T|typed -2 -2 -2"],
        false,
    );
}

/// §10.8: "A return statement in a function" is assignment-like; §12.5 sizes case selector with the int case items; §11.8.2 propagates 32 bits, giving -2/-6 and selecting -2.
#[test]
fn keeps_function_assignment_return_and_case_contexts() {
    check(
        include_str!(
            "constant_expression_context_1096/keeps_function_assignment_return_and_case_contexts.sv"
        ),
        &["T|constant -2 -2 -2 -6 1 7", "T|runtime -2 -2 -2 -6 1"],
        false,
    );
}

/// §10.8 includes "A nondefault correspondence" in an assignment pattern and explicit typed parameter overrides; §23.10.1 sets the parameter via defparam; §11.8.2 yields -2/-6 at 16 or 32 bits.
#[test]
fn keeps_typed_defparam_and_pattern_contexts() {
    check(
        include_str!(
            "constant_expression_context_1096/keeps_typed_defparam_and_pattern_contexts.sv"
        ),
        &["T|dest -2 -6 -2 -2 -6 -2 -6"],
        false,
    );
}

/// §§6.8,10.8 convert to the declared unsigned type; §§11.8.1,11.8.2 give bit patterns 111, fffb, 89, interpreted as 7,65531,137. §11.8.2: "Propagate the type and size of the expression".
#[test]
fn keeps_unsigned_package_variable_types() {
    check(
        include_str!("constant_expression_context_1096/keeps_unsigned_package_variable_types.sv"),
        &["T|package 7 1 7 65531 137 7"],
        false,
    );
}

/// §§10.8,11.8.2 supply 32 bits to multiplication/remainder: U=6, 6*15=90, 90%5=0; §23.10.1 gives defparam the same typed destination. §11.8.2: "Propagate the type and size of the expression".
#[test]
fn keeps_dependent_assignment_contexts() {
    check(
        include_str!("constant_expression_context_1096/keeps_dependent_assignment_contexts.sv"),
        &["T|dependent 0 0 0 0 0"],
        false,
    );
}

/// §11.8.1: "If any operand is unsigned, the result is unsigned"; §§10.8,11.8.2 zero-extend 4-bit PN=1010 to 32 bits before >>>3, giving 1; OR 1 remains 1.
#[test]
fn keeps_dependent_unsigned_shift_context() {
    check(
        include_str!("constant_expression_context_1096/keeps_dependent_unsigned_shift_context.sv"),
        &["T|shift 1 1"],
        false,
    );
}

/// §20.7 $size of the 8-bit vector is 8; §§11.6,11.8 size denominator to 64 bits: (9-8)%(15+3)=1. §6.20.2 unsized untyped parameter range is "of at least 31" MSB; all-ones complement is zero at every permitted width.
#[test]
fn keeps_query_cancellation_and_fill_complement() {
    check(
        include_str!(
            "constant_expression_context_1096/keeps_query_cancellation_and_fill_complement.sv"
        ),
        &["T|fallback 1 0"],
        false,
    );
}

/// §11.6 Table 11-21 self-determines shift counts/exponents and concatenation operands; §6.24.1 sizes casts (4-bit 3+3=6, concat=96). §11.8.2 treats the integral arm as self-determined before real conversion (3-bit 18 wraps to 2); §11.4.11 merges identical arms. §11.8.2: "Propagate the type and size of the expression".
#[test]
fn keeps_self_determined_boundaries_and_real_power() {
    check(
        include_str!(
            "constant_expression_context_1096/keeps_self_determined_boundaries_and_real_power.sv"
        ),
        &["T|boundary 1 1 96 13 2.0 2.0 101"],
        false,
    );
}

/// §11.4.11: if both conditional arms have the same value, the merged result is that value; adding zero preserves zero (§11.4.3). §11.8.2: "Propagate the type and size of the expression".
#[test]
fn keeps_declined_expression_zero() {
    check(
        include_str!("constant_expression_context_1096/keeps_declined_expression_zero.sv"),
        &["T|declined 0"],
        false,
    );
}

/// §§6.16,6.24.1 string casts convert the self-determined 8-bit sum: (122+200)%256=66 (B), length 1; §§10.8,11.8.2 evaluate 9-10 at eight bits, giving ff in the packed member. §11.8.2: "Propagate the type and size of the expression".
#[test]
fn keeps_string_arithmetic_and_packed_type_context() {
    check(
        include_str!(
            "constant_expression_context_1096/keeps_string_arithmetic_and_packed_type_context.sv"
        ),
        &["T|typed-leaves 1 66 1 66 ff"],
        false,
    );
}
