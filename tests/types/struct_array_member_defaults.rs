//! IEEE 1800-2023 §7.2.2 / §7.4.2 / §7.4.4: fixed-array elements
//! initialize from their struct type, except when the variable has an explicit
//! initializer. Sample at #1 to avoid time-zero process ordering (§4.7).

use xezim::simulate;

const FIXED: &str = r#"
module top;
  localparam int ID = 7;
  typedef struct { int n; } inner_t;
  typedef struct {
    int id = ID;
    bit flag = 1;
    logic [7:0] tag = 8'ha5;
    real scale = 1.5;
    string text = "hello";
    inner_t nested = '{11};
    int values[2] = '{3,4};
  } item_t;
  typedef item_t alias_t;
  typedef item_t row_t[2];
  item_t control, a[2], m[-1:0][3:2], cube[1][2][1];
  alias_t descending[2:-1];
  row_t row;
  item_t own[1] = '{'{9,0,8'h3c,2.5,"override",'{12},'{5,6}}};
  item_t own_scalar = '{9,0,8'h3c,2.5,"override",'{12},'{5,6}};
  initial begin
    #1;
    $display("control=%0d array=%0d",control.id,a[0].id);
    $display("fields=%0d,%h,%0.1f,%s,%0d,%0d,%0d",a[1].flag,a[1].tag,a[1].scale,a[1].text,a[1].nested.n,a[1].values[0],a[1].values[1]);
    $display("dimensions=%0d,%0d,%0d,%0d,%0d",m[-1][2].id,m[0][3].id,cube[0][1][0].id,descending[-1].id,row[1].id);
    $display("multi_fields=%h,%0.1f,%s cube_fields=%h,%0.1f,%s",m[-1][2].tag,m[-1][2].scale,m[-1][2].text,cube[0][1][0].tag,cube[0][1][0].scale,cube[0][1][0].text);
    $display("override=%0d,%0d,%h,%0.1f,%s,%0d,%0d,%0d",own[0].id,own[0].flag,own[0].tag,own[0].scale,own[0].text,own[0].nested.n,own[0].values[0],own[0].values[1]);
    $display("scalar_override=%0d,%0d,%h,%0.1f,%s,%0d,%0d,%0d",own_scalar.id,own_scalar.flag,own_scalar.tag,own_scalar.scale,own_scalar.text,own_scalar.nested.n,own_scalar.values[0],own_scalar.values[1]);
    a[0].id = 19;
    $display("independent=%0d,%0d",a[0].id,a[1].id);
    $finish;
  end
endmodule
"#;

#[test]
fn fixed_struct_array_member_defaults() {
    let sim = simulate(FIXED, 100).expect("simulate");
    let got: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    assert_eq!(
        got,
        [
            "control=7 array=7",
            "fields=1,a5,1.5,hello,11,3,4",
            "dimensions=7,7,7,7,7",
            "multi_fields=a5,1.5,hello cube_fields=a5,1.5,hello",
            "override=9,0,3c,2.5,override,12,5,6",
            "scalar_override=9,0,3c,2.5,override,12,5,6",
            "independent=19,7",
        ]
    );
}

// §7.5.1 / §7.10.2 / §8.4 / §13.3: existing runtime initialization
// paths keep the same values. All of these checks already pass on main.
const RUNTIME: &str = r#"
module top;
  typedef struct { int id=7; bit flag=1; string text="hello"; } item_t;
  class holder;
    item_t scalar, a[1];
  endclass
  item_t scalar, d[], q[$];
  holder obj;
  function automatic int f();
    item_t local_scalar, local_array[1];
    return local_scalar.id + local_array[0].id;
  endfunction
  task automatic t();
    item_t local_scalar, local_array[1];
    $display("task=%0d,%0d",local_scalar.id,local_array[0].id);
  endtask
  initial begin
    #1;
    obj=new;
    d=new[2];
    q.push_back(scalar);
    $display("dynamic=%0d,%0d,%s",d[1].id,d[1].flag,d[1].text);
    $display("queue=%0d,%0d,%s",q[0].id,q[0].flag,q[0].text);
    $display("class=%0d,%0d",obj.scalar.id,obj.a[0].id);
    $display("function=%0d",f());
    t();
    $finish;
  end
endmodule
"#;

#[test]
fn runtime_struct_array_defaults_still_work() {
    let sim = simulate(RUNTIME, 100).expect("simulate");
    let got: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    assert_eq!(
        got,
        [
            "dynamic=7,1,hello",
            "queue=7,1,hello",
            "class=7,7",
            "function=14",
            "task=7,7",
        ]
    );
}

/// §6.18 / §7.2.2: moving the default pass must retain the scalar path's
/// existing alias resolution. This legal chain already initializes on main.
#[test]
fn typedef_chain_keeps_scalar_defaults() {
    let mut src = String::from("module top; typedef struct {int id=7;} A0;\n");
    for i in 1..=64 {
        src.push_str(&format!("typedef A{} A{};\n", i - 1, i));
    }
    src.push_str(
        "A64 scalar; initial begin #1; $display(\"scalar=%0d\",scalar.id); $finish; end endmodule",
    );
    let sim = simulate(&src, 100).expect("simulate");
    let got: Vec<_> = sim.output.iter().map(|o| o.message.as_str()).collect();
    assert_eq!(got, ["scalar=7"]);
}
