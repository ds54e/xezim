//! IEEE 1800-2023 §23.10.1 permits defparams of the containing instance.
//! §23.10 gives defparam precedence over an instance override; §23.10.3
//! updates dependent parameters. Shapes use §6.20.2, §7.4 and §27.5;
//! port connections use §23.3.3. All observations occur after settling (§4.7).

use xezim::simulate;

fn messages(src: &str) -> Vec<String> {
    let sim = simulate(src, 100).expect("legal own-instance defparam");
    let mut out: Vec<_> = sim.output.iter().map(|o| o.message.clone()).collect();
    out.sort();
    out
}

const SHAPES: &str = r#"
// IEEE 1800-2023 §23.10.1, §23.10.3, §6.20.2, §7.4, §27.5, §23.3.3.
module drive #(parameter V = 0)(output wire [3:0] y);
  assign y = V;
endmodule
module child;
  parameter int P = 0;
  parameter int K = 0;
  parameter int D = P + 2;
  defparam P = 0;
  defparam child.K = 5;
  defparam P = 1;
  typedef logic [P+2:0] word_t;
  word_t v;
  wire [D-1:0] r;
  wire [3:0] a[2];
  drive #(5) d0(a[P]);
  drive #(7) d1(a[1-P]);
  if (P == 1) begin : good
    initial #1 $display("%m selected");
  end else begin : bad
    initial #1 $display("%m WRONG");
  end
  initial #1 $display("%m P=%0d K=%0d D=%0d bits=%0d range=%0d a0=%0d a1=%0d", P,K,D,$bits(v),$bits(r),a[0],a[1]);
endmodule
module tb;
  parameter int P = 0;
  parameter int D = P + 3;
  defparam tb.P = 2;
  typedef logic [P:0] word_t;
  word_t v;
  wire [D-1:0] r;
  child c1();
  child #(9) c2();
  if (P == 2) begin : good
    initial #1 $display("%m selected");
  end
  initial #1 $display("top P=%0d D=%0d bits=%0d range=%0d", P,D,$bits(v),$bits(r));
endmodule
"#;

#[test]
fn top_and_repeated_children_resolve_shapes_before_connections() {
    assert_eq!(
        messages(SHAPES),
        [
            "tb.c1 P=1 K=5 D=3 bits=4 range=3 a0=7 a1=5",
            "tb.c1.good selected",
            "tb.c2 P=1 K=5 D=3 bits=4 range=3 a0=7 a1=5",
            "tb.c2.good selected",
            "tb.good selected",
            "top P=2 D=5 bits=3 range=5",
        ]
    );
}

#[test]
fn full_paths_and_definition_names_resolve_per_instance() {
    let src = r#"
// §23.10.1, §23.8: full paths and definition names resolve per instance.
module leaf;
  parameter int P = 0;
  parameter int Q = 0;
  defparam tb.a.P = 4;
  defparam leaf.Q = 5;
  initial #1 $display("%m P=%0d Q=%0d", P,Q);
endmodule
module tb;
  leaf a();
  leaf b();
endmodule
"#;
    assert_eq!(messages(src), ["tb.a P=4 Q=5", "tb.b P=0 Q=5"]);
}

#[test]
fn last_defparam_in_source_text_wins() {
    let src = r#"
// §23.10.1: last defparam in source text wins, across module boundaries too.
module earlier;
  parameter int P = 0;
  defparam P = 3;
endmodule
module tb;
  earlier a();
  later b();
  defparam a.P = 7;
  defparam b.P = 7;
  initial #1 $display("a=%0d b=%0d", a.P,b.P);
endmodule
module later;
  parameter int P = 0;
  defparam P = 4;
endmodule
"#;
    assert_eq!(messages(src), ["a=7 b=4"]);
}

// Guards: §23.8 downward scopes shadow a module definition name. These
// values already work on main, as do ordinary child-instance defparams.
#[test]
fn child_and_generate_names_shadow_the_definition_name() {
    let src = r#"
module leaf #(parameter P=0);
  initial #1 $display("%m P=%0d", P);
endmodule
module child;
  parameter int P=1;
  leaf child();
  defparam child.P=6;
  initial #1 $display("%m P=%0d", P);
endmodule
module generated;
  parameter int P=2;
  if (1) begin : generated
    leaf l();
  end
  defparam generated.l.P=7;
  initial #1 $display("%m P=%0d", P);
endmodule
module tb;
  child c();
  generated g();
  leaf d();
  defparam d.P=8;
endmodule
"#;
    assert_eq!(
        messages(src),
        [
            "tb.c P=1",
            "tb.c.child P=6",
            "tb.d P=8",
            "tb.g P=2",
            "tb.g.generated.l P=7",
        ]
    );
}

// §6.20.1/§6.20.4 and §23.10.1: local and type parameters remain errors.
#[test]
fn own_targets_must_be_overridable_value_parameters() {
    for src in [
        "module tb; localparam int P=0; defparam P=1; endmodule",
        "module tb; localparam int P=0; defparam tb.P=1; endmodule",
        "module tb #(parameter Q=0); parameter int P=0; defparam P=1; endmodule",
        "module tb #(parameter Q=0); parameter int P=0; defparam tb.P=1; endmodule",
        "module c #(parameter Q=0); parameter int P=0; defparam c.P=1; endmodule module tb; c u(); endmodule",
        "module tb #(parameter type T=int); defparam tb.T=1; endmodule",
    ] {
        assert!(simulate(src, 10).is_err(), "{src}");
    }
}

// -g changes defaults; -G also replaces defparams (documented CLI policy).
// §23.10 governs the independent #(...) versus defparam precedence check.
#[test]
fn command_line_default_and_forced_overrides() {
    use std::process::Command;
    let dir = std::env::temp_dir().join(format!("own_defparam_cli_{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let src = dir.join("own.sv");
    std::fs::write(
        &src,
        r#"
module child;
  parameter int P=0;
  defparam P=3;
  initial #1 $display("%m P=%0d", P);
endmodule
module tb;
  parameter int P=0;
  defparam tb.P=2;
  child #(9) c();
  initial #1 $display("%m P=%0d", P);
endmodule
"#,
    )
    .unwrap();
    for (args, top, child) in [(vec![], 2, 3), (vec!["-gP=8"], 2, 3), (vec!["-GP=8"], 8, 8)] {
        let out = Command::new(env!("CARGO_BIN_EXE_xezim"))
            .arg("--no-cache")
            .args(args)
            .arg(&src)
            .current_dir(&dir)
            .output()
            .unwrap();
        let stdout = String::from_utf8_lossy(&out.stdout);
        assert!(
            out.status.success(),
            "{stdout} {}",
            String::from_utf8_lossy(&out.stderr)
        );
        assert!(
            stdout.lines().any(|s| s == format!("tb P={top}")),
            "{stdout}"
        );
        assert!(
            stdout.lines().any(|s| s == format!("tb.c P={child}")),
            "{stdout}"
        );
    }
    std::fs::remove_dir_all(&dir).unwrap();
}

// §23.6: $root anchors the full path even when a local child shadows the
// top module's name. The target is still the containing instance (§23.10.1).
#[test]
fn rooted_paths_name_the_containing_instance() {
    let src = r#"
module leaf #(parameter P=0);
  initial #1 $display("%m P=%0d",P);
endmodule
module child;
  parameter int P=0;
  defparam $root.tb.c.P=5;
  initial #1 $display("%m P=%0d",P);
endmodule
module tb;
  parameter int P=0;
  defparam $root.tb.P=4;
  child c();
  leaf tb();
  initial #1 $display("%m P=%0d",P);
endmodule
"#;
    assert_eq!(messages(src), ["tb P=4", "tb.c P=5", "tb.tb P=0"]);
}
