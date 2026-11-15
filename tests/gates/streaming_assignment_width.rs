//! IEEE 1800-2023 §11.4.14: a wider assignment target zero-fills on
//! the right after slice reordering. Self-determined casts retain their width.
use xezim::simulate;

fn check_lines(src: &str, expected: &[&str]) {
    let sim = simulate(src, 10).expect("simulate streaming assignment");
    let lines: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    for line in expected {
        assert!(lines.contains(line), "missing {line:?} in {lines:?}");
    }
}

#[test]
fn compiled_streams_pad_after_reordering() {
    check_lines(
        include_str!("streaming_assignment_width.sv"),
        &[
            "continuous=1234567800000000 procedural=1234567800000000",
            "bits=1e6a2c4800000000 bytes=7856341200000000 forward4=1234567800000000 identity64=1234567800000000",
            "nibble=c5a000 remainder=e4a000 odd=4e00 multi=a5cb40 exact=78563412",
            "huge=bc9a7856341200000000000000000000 struct=a5810000 four_state=10xz001100000000 signed=ff000000",
            "declared=1234567800000000 return=1234567800000000 named=7856341200000000 port=1234567800000000",
            "cast_expr=000000001234567d cast_concat=fedcba9878563412 fallback=1234567800000000",
            "comb=1234567800000000 edge_blocking=1234567800000000 edge_nonblocking=1234567800000000 part=ffffffff12345678 loop=1234567800000000 ternary=1234567800000000",
        ],
    );
}

#[test]
fn streams_use_the_bound_operand_and_dynamic_string_width() {
    // §23.9/§8.23: locals and class members hide the module signal.
    // §6.16/§6.24.3/§11.4.14: strings have no fixed target width.
    check_lines(
        include_str!("streaming_assignment_bindings.sv"),
        &[
            "loop=89abcdef function=89abcdef named=89abcdef package=89abcdef static=89abcdef formal=89abcdef property=89abcdef local=89abcdef",
            "reverse_loop=efcdab89 reverse_function=efcdab89 wide=89abcdef00000000",
            "reverse_constant=efcdab89 shadow_target=1234567800000000",
            "member_range=00000000000000000000000000000005 method_string=AA/2 method_string_reverse=AA/2",
            "string_ca=AB/2 string_comb=AB/2 string_star=AB/2 string_loop=AB/2 string_reverse=BA/2 equal=1",
        ],
    );
}

#[test]
fn stream_string_sources_keep_their_values() {
    // §6.16/§6.24.3/§11.4.14: a string's placeholder is not its width.
    check_lines(
        include_str!("streaming_assignment_string_source.sv"),
        &[
            "small=4142 exact_string=4142434445464748 copy_ca=AB/2 copy_comb=AB/2",
            "large_high=41414141 large_low=41414141 part_high=ffffffff part_low=41414141",
            "root_high=41414141 root_low=41414141 child_high=41414141 child_low=41414141",
            "alias_ca=AB/2 alias_comb=AB/2 class_source=00000000000000000000000000000001 scope_integer=1234567800000000",
        ],
    );
}

#[test]
fn collection_streams_and_unpacking_keep_their_values() {
    check_lines(
        include_str!("streaming_assignment_collections.sv"),
        &[
            "fixed=12340000 dynamic=78560000 queue=9abc0000",
            "unpack=12,34,56,78 dynamic_unpack=11,44 repack=11223344",
        ],
    );
}
