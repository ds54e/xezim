// IEEE 1800-2023 §5.7.1, §6.5, §6.11.2, §7.2.1, §7.4.1, §7.4.2,
// §10.3, §10.4.1, §10.4.2, §10.8, §11.5.1, §11.5.3, §11.8.3:
// contiguous packed members, assignment fitting and selected-element writes.
module top;
  typedef struct packed {logic [1:0][7:0] x; logic [7:0] guard;} pair_t;
  typedef struct packed {logic [1:0][1:0][7:0] x;} cube_t;
  typedef struct packed {pair_t [1:0] lane; logic [7:0] guard;} outer_t;
  typedef struct packed {outer_t [1:0] bank;} tower_t;
  tower_t [1:0] tower;
  typedef struct packed {bit [1:0][7:0] x; logic [7:0] g;} mixed_t;
  mixed_t [1:0] mixed;
  pair_t [1:0] a, n, signed_a;
  pair_t u[0:1];
  pair_t [1:0][1:0] a2;
  pair_t [1:0][1:0][1:0] a3;
  cube_t [1:0] cube;
  outer_t [1:0] deep;
  pair_t single;
  integer i, j, k, base;
  int errors;
  logic [3:0] drive;
  pair_t [1:0] c;
  assign c[1].x[0][5:2] = drive;
  assign c[1].x[0][7:6] = 0;
  assign c[1].x[0][1:0] = 0;
  assign c[1].x[1] = 8'h91;
  assign c[1].guard = 8'h72;
  assign c[0] = '0;

  task automatic check(input string name, input logic [127:0] got, want);
    if (got !== want) begin
      $display("FAIL %s got=%h want=%h", name, got, want);
      errors++;
    end else $display("PASS %s", name);
  endtask

  function automatic logic [7:0] fill(input logic [3:0] v);
    pair_t [1:0] local_a;
    local_a = '0;
    local_a[1].x[0][5:2] = v;
    return local_a[1].x[0];
  endfunction

  initial begin
    errors = 0;
    mixed = '0; mixed[1].g = 'x;
    mixed[1].x[0][5:2] = 4'bxz01;
    check("mixed two state field", mixed[1].x[0], 8'h04);
    check("mixed four state guard", mixed[1].g, 8'hxx);
    a = '0; n = '0; signed_a = '0; u[0] = '0; u[1] = '0;
    tower = '0; a2 = '0; a3 = '0; cube = '0; deep = '0; single = '0;
    i = 1; j = 0; k = 1; base = 2; drive = 4'ha;
    a[0].x[0] = 8'h28;
    a[1].guard = 8'hc3; a[1].x[1] = 8'h96;
    a[1].x[0][5:2] = 4'ha;
    signed_a[1].x[0][5:2] = 2'sb10;
    check("signed narrow rhs", signed_a[1].x[0], 8'h38);
    signed_a[1].x[0][5:2] = '1;
    check("unbased fill rhs", signed_a[1].x[0], 8'h3c);
    check("constant", a[1].x[0], 8'h28);
    check("whole element read write", a[0].x[0], 8'h28);
    check("preserve field and lane", a[1], 24'h9628c3);
    a[i].x[j][base +: 4] = 4'h5;
    check("indexed up variable", a[1].x[0], 8'h14);
    a[i].x[j][base+3 -: 4] = 4'hb;
    check("indexed down variable", a[1].x[0], 8'h2c);
    a[i].x[j][7] = 1;
    check("single bit", a[1].x[0], 8'hac);
    a2[1][0].x[1][5:2] = 4'h6;
    check("two outer indices", a2[1][0].x[1], 8'h18);
    a3[i][j][k].x[j][5:2] = 4'hd;
    check("three outer indices", a3[1][0][1].x[0], 8'h34);
    cube[i].x[k][j][5:2] = 4'h9;
    check("two member indices", cube[1].x[1][0], 8'h24);
    deep[i].lane[k].x[j][5:2] = 4'ha;
    check("nested packed members", deep[1].lane[1].x[0], 8'h28);
    tower[i].bank[k].lane[k].x[j][5:2] = 4'ha;
    check("three nested packed members", tower[1].bank[1].lane[1].x[0], 8'h28);
    u[i].x[j][5:2] = 4'ha;
    check("unpacked array", u[1].x[0], 8'h28);
    check("unpacked neighbor", u[0], 0);
    single.x[0][5:2] = 4'ha;
    check("plain struct", single.x[0], 8'h28);
    a[1].x[0][5:2] = 4'bxz01;
    check("four state", a[1].x[0], 8'b10xz0100);
    a[1].x[0] = 8'ha5;
    base = 6; a[1].x[0][base +: 4] = 4'hf;
    check("partial high", a[1].x[0], 8'he5);
    base = -2; a[1].x[0][base +: 4] = 4'hc;
    check("partial low", a[1].x[0], 8'he7);
    base = 9; a[1].x[0][base +: 4] = 4'h0;
    check("outside slice", a[1].x[0], 8'he7);
    base = 'x;
    a[1].x[0][base +: 4] = 4'h0;
    check("unknown slice", a[1].x[0], 8'he7);
    check("neighbor preserved after clipping", a[1].x[1], 8'h96);
    check("function local", fill(4'ha), 8'h28);
    n[i].x[j][5:2] <= 4'ha;
    #1;
    check("nonblocking", n[1].x[0], 8'h28);
    check("continuous", c[1], 24'h912872);
    drive = 4'h5;
    #1;
    check("continuous update", c[1], 24'h911472);
    if (errors == 0) $display("ALL PASS");
    $finish;
  end
endmodule
