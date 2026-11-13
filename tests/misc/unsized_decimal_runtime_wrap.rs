//! Pin the signed-decimal 32-bit compatibility policy documented above core's
//! `warn_unsized_decimal_wrap` and in `unsized_decimal_wrap_warning.rs`.
//! IEEE 1800-2023 §5.7.1 instead requires a sufficient minimum width; these
//! wrap expectations explicitly follow upstream policy. Unsigned 'd keeps its
//! digits, as required by `unsized_literal_keeps_its_digits.rs`. See the SV for clauses.

use std::process::Command;

#[test]
fn runtime_unsized_decimals_match_parameters_and_warn_once() {
    let dir = std::env::temp_dir().join(format!("xz_decimal_runtime_{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let path = dir.join("top.sv");
    std::fs::write(&path, include_str!("unsized_decimal_runtime_wrap.sv")).unwrap();
    let out = Command::new(env!("CARGO_BIN_EXE_xezim"))
        .arg("--no-cache")
        .arg(&path)
        .current_dir(&dir)
        .output()
        .expect("run xezim");
    let stdout = String::from_utf8_lossy(&out.stdout);
    let stderr = String::from_utf8_lossy(&out.stderr);
    assert!(out.status.success(), "{stdout}\n{stderr}");
    for line in [
        "policy -1454759936 -1454759936 -1454759936 1 1 1",
        "widths 32 32 32 32",
        "direct -1454759936 1",
        "expressions 2 1454759936",
        "real -2909519872",
        "decimal_base 2000000000000 -1454759936 41 32",
        "guards 2147483647 2000000000000 4294967297 -2147483648 64 36",
    ] {
        assert!(
            stdout.lines().any(|s| s == line),
            "missing {line}:\n{stdout}\n{stderr}"
        );
    }
    for literal in ["2000000000000", "4294967297"] {
        assert_eq!(
            stderr
                .matches(&format!("unsized decimal literal '{literal}'"))
                .count(),
            1,
            "expected one deduped warning: {stderr}"
        );
    }
    assert_eq!(stderr.matches("[warning]").count(), 3, "{stderr}");
    std::fs::remove_dir_all(dir).unwrap();
}

// No parameter can emit the warning before the runtime literal sites.
#[test]
fn runtime_only_decimals_warn_once_without_const_eval() {
    let dir = std::env::temp_dir().join(format!("xz_decimal_only_{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let path = dir.join("top.sv");
    std::fs::write(
        &path,
        r#"
module top;
  real x, y;
  wire signed [63:0] a, b;
  assign a = 2000000000000;
  assign b = 4294967297;
  initial begin
    x = 2000000000000;
    y = 4294967297;
    #1;
    $display("only %.0f %.0f %0d %0d", x, y, a, b);
  end
endmodule
"#,
    )
    .unwrap();
    let out = Command::new(env!("CARGO_BIN_EXE_xezim"))
        .arg("--no-cache")
        .arg(&path)
        .current_dir(&dir)
        .output()
        .unwrap();
    let stdout = String::from_utf8_lossy(&out.stdout);
    let stderr = String::from_utf8_lossy(&out.stderr);
    assert!(out.status.success(), "{stdout}\n{stderr}");
    assert!(
        stdout.contains("only -1454759936 1 -1454759936 1"),
        "{stdout}\n{stderr}"
    );
    for literal in ["2000000000000", "4294967297"] {
        assert_eq!(
            stderr
                .matches(&format!("unsized decimal literal '{literal}'"))
                .count(),
            1,
            "{stderr}"
        );
    }
    assert_eq!(stderr.matches("[warning]").count(), 2, "{stderr}");
    std::fs::remove_dir_all(dir).unwrap();
}
