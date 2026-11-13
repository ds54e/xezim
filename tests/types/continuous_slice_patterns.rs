//! IEEE 1800-2023 §7.4.6 / §7.6 / §10.9.1: continuous slice
//! patterns bind items to the selected elements; §10.3 reevaluates items.
use std::process::Command;

fn run(compiled: bool) {
    let output = Command::new("bash")
        .args([
            "-c",
            "ulimit -v 4000000; exec timeout 60 \"$@\"",
            "slice-patterns",
        ])
        .arg(env!("CARGO_BIN_EXE_xezim"))
        .args(["--no-cache", "-s", "top"])
        .arg(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/tests/types/continuous_slice_patterns.sv"
        ))
        .env("XEZIM_COMPILE_METHODS", if compiled { "1" } else { "0" })
        .env("XEZIM_METHOD_TIER", "0")
        .env_remove("XEZIM_METHOD_CACHE")
        .output()
        .expect("run continuous slice patterns");
    let transcript = format!(
        "{}{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    assert!(output.status.success(), "{transcript}");
    assert!(!transcript.contains("FAIL"), "{transcript}");
    for line in [
        "PASS child",
        "PASS generate 0",
        "PASS generate 1",
        "PASS continuous slice patterns",
    ] {
        assert!(transcript.contains(line), "{transcript}");
    }
}

#[test]
fn interpreted_continuous_slice_patterns() {
    run(false);
}

#[test]
fn compiled_continuous_slice_patterns() {
    run(true);
}
