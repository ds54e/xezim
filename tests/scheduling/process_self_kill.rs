//! IEEE 1800-2023 §9.7: a process killing itself stops at the call, even
//! inside a task, method or loop; its descendants terminate and report KILLED.

fn check(src: &str, expected: &[&str]) {
    let sim = xezim::simulate(src, 20_000).expect("simulate");
    let lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    assert!(!lines.iter().any(|m| m.contains("FAIL")), "{lines:?}");
    for tag in expected {
        assert!(
            lines.contains(&format!("PASS {tag}").as_str()),
            "{tag}: {lines:?}"
        );
    }
}

#[test]
fn self_kill_unwinds_process_and_subroutine_contexts() {
    check(
        include_str!("process_self_kill_contexts.sv"),
        &[
            "initial",
            "join",
            "join_any",
            "join_none",
            "task",
            "delayed_task",
            "function",
            "alias",
            "method",
            "delayed_method",
            "always",
            "compiled_method",
            "parent_stop",
            "descendants",
        ],
    );
}

#[test]
fn self_kill_unwinds_every_loop_body() {
    check(
        include_str!("process_self_kill_loops.sv"),
        &["for", "while", "do", "repeat", "foreach", "forever"],
    );
}

#[test]
fn self_kill_does_not_unwind_another_nested_scheduler_caller() {
    check(
        include_str!("process_self_kill_nested.sv"),
        &["nested_survivor", "nested_self_kill"],
    );
    check(
        include_str!("process_self_kill_nested_leaks.sv"),
        &["nested_edges", "nested_return"],
    );
}

#[test]
fn other_process_control_keeps_its_continuation() {
    check(
        include_str!("process_self_kill_guards.sv"),
        &[
            "ordinary_kill_method",
            "kill_other",
            "suspend_resume",
            "await_finished",
            "await_killed",
            "disable",
        ],
    );
}

// §9.2.3 and §9.7: a killed activation cannot carry execution control into
// independent final, combinational, clocked, or same-slot NBA work.
fn check_lines(src: &str, expected: &[&str]) {
    let sim = xezim::simulate(src, 200_000).expect("simulate");
    let lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    assert!(!lines.iter().any(|m| m.contains("FAIL")), "{lines:?}");
    for line in expected {
        assert!(lines.contains(line), "{line}: {lines:?}");
    }
}

#[test]
fn self_kill_preserves_final_at_natural_completion() {
    check_lines(
        include_str!("process_self_kill_final_minimal.sv"),
        &["FINAL must run"],
    );
    check_lines(
        include_str!("process_self_kill_final_natural.sv"),
        &["FINAL natural x=1"],
    );
}

#[test]
fn self_kill_preserves_independent_comb_and_edge_work() {
    check_lines(
        include_str!("process_self_kill_leak_break.sv"),
        &["PASS encoder bad=0 n_q=10"],
    );
    check_lines(include_str!("process_self_kill_leak_m3.sv"), &["PASS b=10"]);
    check_lines(
        include_str!("process_self_kill_slot_nba.sv"),
        &["PASS nba_edge"],
    );
}

#[test]
fn self_kill_preserves_final_methods_at_explicit_finish() {
    check_lines(
        include_str!("process_self_kill_leak_final.sv"),
        &["PASS final f1=1 f2=7", "final done"],
    );
}

#[test]
fn optimized_edge_kill_keeps_independent_bodies_and_final() {
    // The edge block still borrows a PID (§9.7 limit). Check only independent
    // work whose expected value is correct on main; do not pin post-kill work.
    check_lines(
        include_str!("process_self_kill_edge_final.sv"),
        &["PASS edge final"],
    );
    check_lines(
        include_str!("process_self_kill_e_two.sv"),
        &["PASS block_b", "PASS block_c"],
    );
    check_lines(
        include_str!("process_self_kill_e_gen.sv"),
        &["PASS block_b", "PASS tb_alive"],
    );
    check_lines(
        include_str!("process_self_kill_e_other.sv"),
        &["PASS kill_clock_driver", "PASS kill_unrelated"],
    );
}
