//! IEEE 1800-2023 §28.4/§28.5: z inputs yield x through delayed logic
//! gates; §28.3.5/§28.3.6 cover instance arrays. §28.6 tristates and
//! §10.3 continuous assignments retain their own four-state behavior.

#[test]
fn delayed_logic_gates_convert_z_inputs() {
    for (src, checks) in [
        (include_str!("delayed_logic_z.sv"), 64),
        (include_str!("delayed_logic_z_guards.sv"), 8),
        (include_str!("delayed_logic_real.sv"), 4),
        (include_str!("delayed_logic_wide.sv"), 3),
    ] {
        let sim = xezim::simulate(src, 1_000_000).expect("simulate failed");
        let got: Vec<_> = sim.output.iter().map(|o| o.message.trim()).collect();
        assert_eq!(
            got.iter().filter(|s| s.starts_with("PASS")).count(),
            checks,
            "{got:#?}"
        );
        assert!(!got.iter().any(|s| s.starts_with("FAIL")), "{got:#?}");
    }
}
