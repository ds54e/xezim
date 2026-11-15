//! IEEE 1800-2023 §9.6.2: named fork activities belong to their declaring
//! instance and lexical block (§23.9, §27.4). §9.6.1 wait fork and §9.6.3
//! disable fork remain tied to the calling process. Stimulus and sampling
//! occur at distinct times (§4.7); every checked line follows from the LRM.
use xezim::simulate;

fn check(src: &str, expected: &[&str]) {
    let sim = simulate(src, 100_000).expect("simulate");
    let lines: Vec<_> = sim
        .output
        .iter()
        .map(|o| o.message.trim_end())
        .filter(|s| s.starts_with("T|"))
        .collect();
    assert_eq!(lines, expected);
}

#[test]
fn instances() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  bit go;
  int w, e, d, f, sub, done;
  initial begin
    fork : dl
      #1;
      begin wait(go == 1); w = 1; end
      begin @(posedge go); e = 1; end
      begin #5; d = 1; end
      begin
        fork begin #5; sub = 1; end join_none
        wait fork;
        f = 1;
      end
    join_any
    disable dl;
    wait fork;
    done = 1;
  end
  initial #3 go = 1;
endmodule
module other;
  int seen;
  initial begin
    fork : dl begin #5; seen = 1; end join
  end
endmodule
module top;
  child a(), b(), c();
  for (genvar i = 0; i < 3; i++) begin : g
    child u();
  end
  other o();
  initial begin
    #8;
    $display("T|abc %0d%0d%0d %0d%0d%0d %0d%0d%0d %0d%0d%0d %0d%0d%0d %0d%0d%0d",
      a.w,b.w,c.w, a.e,b.e,c.e, a.d,b.d,c.d, a.f,b.f,c.f,
      a.sub,b.sub,c.sub, a.done,b.done,c.done);
    $display("T|gen %0d%0d%0d %0d%0d%0d %0d%0d%0d %0d%0d%0d %0d%0d%0d %0d%0d%0d other=%0d",
      g[0].u.w,g[1].u.w,g[2].u.w, g[0].u.e,g[1].u.e,g[2].u.e,
      g[0].u.d,g[1].u.d,g[2].u.d, g[0].u.f,g[1].u.f,g[2].u.f,
      g[0].u.sub,g[1].u.sub,g[2].u.sub, g[0].u.done,g[1].u.done,g[2].u.done,o.seen);
    $finish;
  end
endmodule
"#,
        &[
            "T|abc 000 000 000 000 000 111",
            "T|gen 000 000 000 000 000 111 other=1",
        ],
    );
}

#[test]
fn hierarchical() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  int seen, done;
  initial begin
    fork : dl begin #5; seen = 1; end join
    done = 1;
  end
endmodule
module top;
  child a(), b();
  initial begin
    #1; disable a.dl;
    #7; $display("T|%0d %0d done=%0d%0d", a.seen,b.seen,a.done,b.done);
    $finish;
  end
endmodule
"#,
        &["T|0 1 done=11"],
    );
}

#[test]
fn nested() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  int inner_hit, outer_hit, done;
  initial begin
    begin : outer
      fork : dl begin #6; outer_hit = 1; end join_none
      begin : inner
        fork : dl begin #6; inner_hit = 1; end join_none
        #1; disable dl;
      end
      wait fork;
      done = 1;
    end
  end
endmodule
module top;
  child a(), b();
  initial begin #9; $display("T|inner=%0d%0d outer=%0d%0d done=%0d%0d",a.inner_hit,b.inner_hit,a.outer_hit,b.outer_hit,a.done,b.done); $finish; end
endmodule
"#,
        &["T|inner=00 outer=11 done=11"],
    );
}

#[test]
fn guards() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  int bhit, taskhit, tail, fhit, unrelated;
  task automatic t();
    #1; disable t;
    taskhit = 1;
  endtask
  initial begin
    begin : blk
      #1; disable blk;
      bhit = 1;
    end
    t();
    tail = 1;
  end
  initial begin
    fork begin #6; fhit = 1; end join_none
    #2; disable fork;
    wait fork;
  end
  initial begin
    fork : keep begin #6; unrelated = 1; end join
  end
endmodule
module top;
  child a(), b();
  initial begin
    #9; $display("T|begin=%0d%0d task=%0d%0d tail=%0d%0d fork=%0d%0d unrelated=%0d%0d",a.bhit,b.bhit,a.taskhit,b.taskhit,a.tail,b.tail,a.fhit,b.fhit,a.unrelated,b.unrelated);
    $finish;
  end
endmodule
"#,
        &["T|begin=00 task=00 tail=11 fork=00 unrelated=11"],
    );
}

#[test]
fn task_forks() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  int seen, done;
  task automatic t();
    fork : dl begin #5; seen = 1; end join_none
  endtask
  initial begin
    t();
    #1; disable t.dl;
    wait fork;
    done = 1;
  end
endmodule
module top;
  child a(), b();
  initial begin #8; $display("T|%0d%0d done=%0d%0d",a.seen,b.seen,a.done,b.done); $finish; end
endmodule
"#,
        &["T|00 done=11"],
    );
}

#[test]
fn hier_generate() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  int seen;
  initial fork : dl begin #5; seen = 1; end join
endmodule
module top;
  for(genvar i=0;i<3;i++) begin : g child u(); end
  initial begin
    #1; disable g[1].u.dl;
    #7; $display("T|%0d%0d%0d", g[0].u.seen,g[1].u.seen,g[2].u.seen); $finish;
  end
endmodule
"#,
        &["T|101"],
    );
}

#[test]
fn inside_one() {
    check(
        r#"
`timescale 1ns/1ps
module child;
  int seen, done;
  initial begin
    fork : dl
      begin #1; disable dl; seen = 9; end
      begin #5; seen = 1; end
    join
    done = 1;
  end
endmodule
module top;
  child a();
  initial begin #8; $display("T|%0d done=%0d", a.seen,a.done); $finish; end
endmodule
"#,
        &["T|0 done=1"],
    );
}

#[test]
fn parameter_index_fallback() {
    check(
        r#"
`timescale 1ns/1ps
module child;
 int seen;
 initial fork : dl begin #5; seen=1; end join
endmodule
module top;
 localparam int I=2;
 for(genvar i=0;i<3;i++) begin : g child u(); end
 initial begin #1; disable g[I].u.dl; #7; $display("T|%0d%0d%0d",g[0].u.seen,g[1].u.seen,g[2].u.seen); $finish; end
endmodule
"#,
        &["T|110"],
    );
}

// §23.9: an inactive nearer declaration must not select an outer fork.
#[test]
fn inactive_nearer_declaration_fallback() {
    check(
        r#"
`timescale 1ns/1ps
module child;
 int seen;
 initial begin : outer
   fork : dl begin #5; seen=1; end join_none
   begin : inner
     if (0) fork : dl #5; join_none
     #1; disable dl;
   end
 end
endmodule
module other;
 initial fork : dl #6; join_none
endmodule
module top;
 child a(); other b();
 initial begin #8; $display("T|%0d", a.seen); $finish; end
endmodule
"#,
        &["T|1"],
    );
}

// §5.6.1: dots in escaped identifiers are part of the identifier.
#[test]
fn escaped_label_does_not_alias_a_scope_path() {
    check(
        r#"
`timescale 1ns/1ps
module child;
 int seen;
 initial begin
  fork : dl #1; begin #5; seen=1; end join_any
  disable dl;
 end
endmodule
module top;
 int seen;
 child u();
 initial begin
  fork : \u.dl  #1; begin #5; seen=1; end join_any
  disable \u.dl ;
 end
 initial begin #8; $display("T|%0d%0d",seen,u.seen); $finish; end
endmodule
"#,
        &["T|00"],
    );
}

// §5.7.1: 2'sb11 denotes -1, not the unsigned spelling value 3.
#[test]
fn signed_selector_fallback() {
    check(
        r#"
`timescale 1ns/1ps
module child;
 int seen;
 initial fork : dl begin #5; seen=1; end join
endmodule
module top;
 for(genvar i=3;i>=-1;i--) begin : g child u(); end
 initial begin
  #1; disable g[2'sb11].u.dl;
  #7; $display("T|%0d%0d%0d%0d%0d",g[3].u.seen,g[2].u.seen,g[1].u.seen,g[0].u.seen,g[-1].u.seen); $finish;
 end
endmodule
"#,
        &["T|11110"],
    );
}

// §5.6.1, §23.9: ambiguous scope spellings keep the legacy lookup.
#[test]
fn escaped_process_label() {
    check(
        r#"
`timescale 1ns/1ps
module child;
 int seen;
 initial begin : dl
  fork : f #1; begin #5; seen=1; end join_any
  disable f;
 end
endmodule
module other;
 int seen;
 initial begin
  #0.5;
  fork : f #1; begin #5; seen=1; end join_any
  disable f;
 end
endmodule
module top;
 int seen;
 child u(); other c();
 initial begin : \u.dl 
  #0.25;
  fork : f begin #5; seen=1; end join
 end
 initial begin #8; $display("T|%0d%0d%0d",seen,u.seen,c.seen); $finish; end
endmodule
"#,
        &["T|100"],
    );
}

// §5.6.1, §23.9: ambiguous scope spellings keep the legacy lookup.
#[test]
fn root_shadow() {
    check(
        r#"
`timescale 1ns/1ps
module child #(parameter int START=0, KILL=0);
 int seen;
 initial begin
  #START;
  fork : dl #1; begin #5; seen=1; end join_any
  if(KILL) disable dl;
 end
endmodule
module holder;
 child #(.START(3)) a();
endmodule
module top;
 child a(); holder top(); child #(.KILL(1)) o();
 initial begin
  #1; disable top.a.dl;
  #8; $display("T|%0d%0d%0d",a.seen,top.a.seen,o.seen); $finish;
 end
endmodule
"#,
        &["T|110"],
    );
}
