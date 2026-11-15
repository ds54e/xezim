// IEEE 1800-2023 §6.6, §7.2.1, §7.4.1, §7.4.2, §10.4.1, §11.5.1.
module top;
  typedef struct packed {logic [1:0][7:0] x; logic [7:0] g;} t;
  t [1:0] a, wide_a, wide_b, slice_a, slice_b;
  t [-1:-2] wrap_a, wrap_b;
  logic [127:0] wide_index;
  logic [63:0] unsigned_index;
  supply0 t [1:0] s0;
  supply1 t [1:0] s1;
  assign s0[1].x[0][5:2] = 4'ha;
  assign s1[1].x[0][5:2] = 4'ha;
  integer bad;
  int errors;
  task automatic check(input string name, input logic [47:0] want);
    if (a !== want) begin $display("FAIL %s %h",name,a); errors++; end
    else $display("PASS %s",name);
  endtask
  initial begin
    errors=0; a='0;
    wide_a='0; wide_b='0; slice_a='0; slice_b='0;
    wrap_a='0; wrap_b='0;
    wide_index=128'h10000000000000000;
    unsigned_index=64'hffffffffffffffff;
    wide_a[wide_index].x[0][5:2]=4'ha;
    wide_b[wide_index].x[0][5:2]<=4'ha;
    slice_a[1].x[0][wide_index+:4]=4'ha;
    slice_b[1].x[0][wide_index+:4]<=4'ha;
    wrap_a[unsigned_index].x[0][5:2]=4'ha;
    wrap_b[unsigned_index].x[0][5:2]<=4'ha;
    a[1].x[0][7]=1;
    check("independent bit",48'h008000000000);
    a[1].x[1]=8'h96; a[1].g=8'ha5;
    check("whole element and field",48'h9680a5000000);
    bad=2; a[bad].x[0][5:2]=4'hf;
    check("outside root",48'h9680a5000000);
    a[0].x[bad][5:2]=4'hf;
    check("outside member",48'h9680a5000000);
    bad='x; a[bad].x[0][5:2]=4'hf;
    check("unknown root",48'h9680a5000000);
    a[0].x[bad][5:2]=4'hf;
    check("unknown member",48'h9680a5000000);
    bad=9; a[1].x[0][bad+:4]=4'hf;
    check("outside selected byte",48'h9680a5000000);
    bad='x; a[1].x[0][bad+:4]=4'hf;
    check("unknown selected byte",48'h9680a5000000);
    #1;
    if(wide_a==='0 && wide_b==='0) $display("PASS wide index");
    else begin $display("FAIL wide index"); errors++; end
    if(slice_a==='0 && slice_b==='0) $display("PASS wide slice base");
    else begin $display("FAIL wide slice base"); errors++; end
    if(wrap_a==='0 && wrap_b==='0) $display("PASS unsigned index overflow");
    else begin $display("FAIL unsigned index overflow"); errors++; end
    if(s0[1].x[0][5:2]===4'h0) $display("PASS supply zero");
    else begin $display("FAIL supply zero"); errors++; end
    if(s1[1].x[0][5:2]===4'hf) $display("PASS supply one");
    else begin $display("FAIL supply one"); errors++; end
    if(errors==0) $display("ALL PASS");
    $finish;
  end
endmodule
