//! IEEE 1800-2023 §11.4.13, §18.5.3, and §19.5.1: tolerance ranges
//! in set membership, distribution items, and covergroup value bins.

use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn check_output(source: &str, expected: &str) {
    // The parser's standard selection is process-wide. Each CLI invocation
    // can select 1800-2023 independently of the other tests in this suite.
    let scratch = Command::new("mktemp")
        .arg("-d")
        .arg(std::env::temp_dir().join("xezim-tolerance.XXXXXX"))
        .output()
        .expect("run mktemp");
    assert!(scratch.status.success(), "{scratch:?}");
    let dir = PathBuf::from(std::str::from_utf8(&scratch.stdout).unwrap().trim_end());
    fs::write(dir.join("top.sv"), source).expect("write temporary source");
    let output = Command::new(env!("CARGO_BIN_EXE_xezim"))
        .args(["--sv2023", "--no-cache", "top.sv"])
        .current_dir(&dir)
        .output();
    fs::remove_dir_all(dir).expect("remove temporary directory");
    let output = output.expect("run xezim");
    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(
        output.status.success(),
        "xezim exited with {}\n{stdout}{stderr}",
        output.status
    );
    assert!(
        stdout.lines().any(|line| line == expected),
        "expected {expected:?}\n{stdout}{stderr}"
    );
}

fn check_integral_bins(first: &str, second: &str, misses: (i32, i32), hits: (i32, i32)) {
    // §19.11: each hit bin contributes half the instance coverage.
    let (miss_first, miss_second) = misses;
    let (hit_first, hit_second) = hits;
    check_output(
        &format!(
            r#"
`timescale 1ns/1ps
module top;
  int value;
  covergroup cg;
    option.per_instance = 1;
    cp: coverpoint value {{
      bins first = {{[{first}]}};
      bins second = {{[{second}]}};
    }}
  endgroup
  cg inst = new;
  real before_hits, after_first;
  initial begin
    value = {miss_first};
    #1 inst.sample();
    #1 value = {miss_second};
    #1 inst.sample();
    before_hits = inst.get_inst_coverage();
    #1 value = {hit_first};
    #1 inst.sample();
    after_first = inst.get_inst_coverage();
    #1 value = {hit_second};
    #1 inst.sample();
    $display("coverage %0.0f %0.0f %0.0f",
             before_hits, after_first, inst.get_inst_coverage());
    $finish;
  end
endmodule
"#
        ),
        "coverage 0 50 100",
    );
}

#[test]
fn integral_bins_accept_absolute_and_relative_tolerances() {
    // §11.4.13, §19.5.1: the resulting bins are [3:7] and [90:110].
    check_integral_bins("5 +/- 2", "100 +%- 10.0", (8, 111), (7, 110));
}

#[test]
fn real_bins_accept_absolute_and_relative_tolerances() {
    // §19.5.1 permits both delimiters in real bin declarations.
    check_output(
        r#"
`timescale 1ns/1ps
module top;
  real value;
  covergroup cg;
    cp: coverpoint value {
      bins absolute = {[8.5 +/- 0.125]};
      bins relative = {[100.0 +%- 1.0]};
    }
  endgroup
  initial begin
    $display("PASS");
    $finish;
  end
endmodule
"#,
        "PASS",
    );
}

fn check_dist(range: &str, weight: &str) {
    // §18.5.3: both positive weights admit the inclusive endpoints of [9:11]
    // and exclude 8. Use inline constraints (§18.7) to force each candidate.
    check_output(
        &format!(
            r#"
`timescale 1ns/1ps
class item;
  rand int value;
  constraint c {{ value dist {{ [{range}] {weight} 1 }}; }}
endclass
module top;
  initial begin
    item obj;
    bit lo, hi, outside;
    obj = new;
    lo = obj.randomize() with {{ value == 9; }};
    hi = obj.randomize() with {{ value == 11; }};
    outside = obj.randomize() with {{ value == 8; }};
    $display("dist %0d %0d %0d", lo, hi, outside);
    $finish;
  end
endmodule
"#
        ),
        "dist 1 1 0",
    );
}

#[test]
fn dist_absolute_tolerance_with_each_weight() {
    check_dist("10 +/- 1", ":=");
}

#[test]
fn dist_absolute_tolerance_with_total_weight() {
    check_dist("10 +/- 1", ":/");
}

#[test]
fn dist_relative_tolerance_with_each_weight() {
    check_dist("10 +%- 10", ":=");
}

#[test]
fn dist_relative_tolerance_with_total_weight() {
    check_dist("10 +%- 10", ":/");
}

#[test]
fn real_dist_accepts_absolute_and_relative_tolerances() {
    // §18.5.3 requires :/ and an explicit weight for real ranges.
    check_output(
        r#"
`timescale 1ns/1ps
class item;
  rand real value;
  constraint c { value dist { [8.5 +/- 0.125] :/ 1, [100.0 +%- 1.0] :/ 1 }; }
endclass
module top;
  initial begin
    $display("PASS");
    $finish;
  end
endmodule
"#,
        "PASS",
    );
}

#[test]
fn inside_truncates_relative_tolerance_before_forming_integral_bounds() {
    // §11.4.13: 25% of 7 truncates from 1.75 to 1, giving [6:8].
    check_output(
        r#"
`timescale 1ns/1ps
module top;
  int center;
  initial begin
    center = 7;
    $display("inside %0d %0d %0d %0d",
             5 inside {[center +%- 25]}, 6 inside {[center +%- 25]},
             8 inside {[center +%- 25]}, 9 inside {[center +%- 25]});
    $finish;
  end
endmodule
"#,
        "inside 0 1 1 0",
    );
}

#[test]
fn inside_truncates_real_absolute_tolerance_for_an_integral_center() {
    // §11.4.13: truncate 1.75 to 1, giving [6:8] even for real probes.
    check_output(
        r#"
`timescale 1ns/1ps
module top;
  int center;
  initial begin
    center = 7;
    $display("inside %0d %0d %0d %0d",
             5.5 inside {[center +/- 1.75]}, 6.0 inside {[center +/- 1.75]},
             8.0 inside {[center +/- 1.75]}, 8.5 inside {[center +/- 1.75]});
    $finish;
  end
endmodule
"#,
        "inside 0 1 1 0",
    );
}

#[test]
fn inside_orders_the_bounds_for_negative_tolerances() {
    // §11.4.13 orders the two bounds, so both forms mean [9:11].
    check_output(
        r#"
`timescale 1ns/1ps
module top;
  initial begin
    $display("inside %0d %0d %0d %0d",
             9 inside {[10 +/- (-1)]}, 11 inside {[10 +/- (-1)]},
             9 inside {[10 +%- (-10)]}, 11 inside {[10 +%- (-10)]});
    $finish;
  end
endmodule
"#,
        "inside 1 1 1 1",
    );
}

#[test]
fn integral_bin_colon_ranges_allow_addition_and_shift_in_lower_bounds() {
    // §19.5.1: the lower bounds evaluate to 3 and 4, respectively.
    check_integral_bins("1+2:7", "1<<2:5", (2, 8), (7, 4));
}

#[test]
fn dist_colon_range_with_each_weight() {
    check_dist("9:11", ":=");
}

#[test]
fn dist_colon_range_with_total_weight() {
    check_dist("9:11", ":/");
}
