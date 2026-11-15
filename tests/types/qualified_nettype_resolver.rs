//! IEEE 1800-2023 §6.6.7, §8.6, §26.3: scoped nettype resolvers use
//! ordinary package functions or static class methods, including aliases.

fn check(src: &str, expected: &[&str]) {
    let result = xezim::simulate(src, 10_000).expect("scoped nettype must elaborate");
    let lines: Vec<_> = result
        .output
        .iter()
        .map(|line| line.message.trim())
        .collect();
    assert_eq!(lines, expected);
}

macro_rules! real_case {
    ($name:ident) => {
        #[test]
        fn $name() {
            check(
                include_str!(concat!(
                    "qualified_nettype_resolver/",
                    stringify!($name),
                    ".sv"
                )),
                &["NET 3.75", "NET 5.75", "PASS"],
            );
        }
    };
}

real_case!(class);
real_case!(package);
real_case!(packaged_class);
real_case!(class_scope_collision);
real_case!(shadow);
real_case!(alias);
real_case!(imported);
real_case!(package_class_vs_unit);
real_case!(package_class_vs_module);
real_case!(module_class_vs_unit);
real_case!(escaped_resolver_collision);
real_case!(escaped_import_vs_classes);
real_case!(module_class_vs_package);
real_case!(package_function_vs_hidden_class);
real_case!(unqualified_unit);
real_case!(unqualified_module);
real_case!(unqualified_package);

#[test]
fn struct_resolver() {
    check(
        include_str!("qualified_nettype_resolver/struct.sv"),
        &["NET 3.75 30.00", "NET 5.75 30.00", "PASS"],
    );
}

/// §6.6.7 requires static class methods; this checks rejection, never a value.
#[test]
fn nonstatic_class_method_is_rejected() {
    let src = r#"
class C;
  function real res(input real d[]);
    res = 0.0;
    foreach (d[i]) res += d[i];
  endfunction
endclass
nettype real N with C::res;
module top; N n; assign n = 1.25; endmodule
"#;
    let error = xezim::simulate(src, 10_000)
        .err()
        .expect("nonstatic resolver must fail");
    assert!(error.contains("must be a class static method"), "{error}");
}

/// §6.6.7 permits a declaration whose static resolver is never invoked.
#[test]
fn unused_static_class_resolvers_are_legal() {
    check(
        include_str!("qualified_nettype_resolver/unused_class.sv"),
        &["PASS"],
    );
}

/// §6.6.7 requires static methods at declaration, even without any nets.
#[test]
fn unused_nonstatic_class_method_is_rejected() {
    let class = r#"
class C;
  function real res(input real d[]); return 0.0; endfunction
endclass
"#;
    for body in [
        "nettype real N with C::res; module top; initial #1 $finish; endmodule",
        "module top; nettype real N with C::res; initial #1 $finish; endmodule",
    ] {
        let src = format!("{class}\n{body}");
        let error = xezim::simulate(&src, 10_000)
            .err()
            .expect("unused nonstatic resolver must fail");
        assert!(error.contains("must be a class static method"), "{error}");
    }
}

/// §23.7.1 / §26.3: distinct declaring packages retain distinct class scopes.
#[test]
fn two_package_classes() {
    check(
        include_str!("qualified_nettype_resolver/two_package_classes.sv"),
        &["NET 3.75 1003.75", "NET 5.75 1005.75", "PASS"],
    );
}

/// §6.6.7: a class resolver must take a dynamic array, not a fixed array.
#[test]
fn fixed_class_resolver_formal_is_rejected() {
    let error = xezim::simulate(
        r#"
class C;
  static function real res(input real d[2]); return d[0]; endfunction
endclass
nettype real N with C::res;
module top; initial #1 $finish; endmodule
"#,
        10_000,
    )
    .err()
    .expect("fixed array resolver must fail");
    assert!(error.contains("must take a dynamic array"), "{error}");
}
