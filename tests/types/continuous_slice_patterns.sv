// IEEE 1800-2023 §7.4.6, §7.6, §10.9.1: pattern items bind to
// the selected unpacked range, in left-to-right order. Samples are away
// from stimulus times (§4.7); each driven variable has one writer (§6.5).
`timescale 1ns/1ps
module slice_child #(parameter L=1, R=2)(input logic [3:0] x);
  wire [3:0] w[0:3];
  assign w[L:R] = '{x, x+4'd1};
  initial begin
    #2;
    if (w[L] !== 3 || w[R] !== 4) $fatal(1,"FAIL child");
    #3;
    if (w[L] !== 7 || w[R] !== 8) $fatal(1,"FAIL child update");
    $display("PASS child");
  end
endmodule
module top;
  parameter L=1, R=2, N=2;
  typedef struct packed {logic [3:0] a,b;} pair_t;
  logic [3:0] x;
  logic y;
  pair_t s,t;
  wire [3:0] w[0:3], d[3:0], up[0:3], down[3:0];
  wire [3:0] updown[0:3], downup[3:0];
  logic [3:0] v[0:3];
  wire [3:0] keys[0:3], keys0[0:3], def[3:0], rep[0:3];
  wire [3:0] neg[-3:0], negd[0:-3];
  wire scalar[0:3];
  wire [3:0] genw[0:3];
  wire pair_t structs[0:3];
  wire [3:0] matrix[0:3][2:1];
  wire [8:0] wide[0:3];
  logic [7:0] a,b;
  wire [3:0] xz[0:3];
  logic [3:0] proc[0:3], src[0:1];
  wire [3:0] copy[0:3], whole[1:0];
  assign w[L:R] = '{x, x+4'd1};
  assign w[0] = 4'ha;
  assign w[3] = 4'hb;
  assign d[2:1] = '{x, x+4'd1};
  assign v[1:2] = '{x, x+4'd1};
  assign up[L+:N] = '{x, x+4'd1};
  assign down[R-:N] = '{x, x+4'd1};
  assign updown[R-:N] = '{x, x+4'd1};
  assign downup[L+:N] = '{x, x+4'd1};
  assign keys[L:R] = '{(R):x+4'd1, (L):x};
  assign keys0[0:1] = '{0:x, 1:x+4'd1};
  assign def[2:1] = '{2:x, default:x+4'd1};
  assign rep[1:2] = '{N{x}};
  assign neg[-2:-1] = '{x,x+4'd1};
  assign negd[-1:-2] = '{x,x+4'd1};
  assign scalar[1:2] = '{1'b0,1'b1};
  // §7.2 / §10.9.1: struct-valued items retain their element type.
  assign structs[1:2] = '{s,t};
  assign matrix[1:2] = '{'{x,x+4'd1},'{x+4'd2,x+4'd3}};
  // §11.6: each item takes its element's width, including arithmetic.
  assign wide[1:2] = '{a+b, 9'd1};
  assign xz[1:2] = '{4'b10xz,4'bz01x};
  assign copy[1:2] = src;
  assign whole = '{x,x+4'd1};
  slice_child u(x);
  for(genvar g=0;g<2;g++) begin: gen
    assign genw[2*g+:2] = '{y,!y};
    initial begin
      #2;
      if (genw[2*g] !== 0 || genw[2*g+1] !== 1) $fatal(1,"FAIL generate");
      #3;
      if (genw[2*g] !== 1 || genw[2*g+1] !== 0) $fatal(1,"FAIL generate update");
      $display("PASS generate %0d",g);
    end
  end
  task automatic check(input string name, input logic ok);
    if (ok !== 1'b1) $fatal(1,"FAIL %s",name);
    $display("PASS %s",name);
  endtask
  task automatic check_values(input logic [3:0] val);
    check("ascending",w[1] === val && w[2] === val+4'd1);
    check("descending",d[2] === val && d[1] === val+4'd1);
    check("variable",v[1] === val && v[2] === val+4'd1);
    check("indexed up",up[1] === val && up[2] === val+4'd1);
    check("indexed down",down[2] === val && down[1] === val+4'd1);
    check("indexed cross",updown[1] === val && updown[2] === val+4'd1 && downup[2] === val && downup[1] === val+4'd1);
    check("keys",keys[1] === val && keys[2] === val+4'd1 && keys0[0] === val && keys0[1] === val+4'd1);
    check("default",def[2] === val && def[1] === val+4'd1);
    check("replication",rep[1] === val && rep[2] === val);
    check("negative",neg[-2] === val && neg[-1] === val+4'd1 && negd[-1] === val && negd[-2] === val+4'd1);
    check("matrix",matrix[1][2] === val && matrix[1][1] === val+4'd1 && matrix[2][2] === val+4'd2 && matrix[2][1] === val+4'd3);
    check("other drivers",w[0] === 4'ha && w[3] === 4'hb);
    check("whole control",whole[1] === val && whole[0] === val+4'd1);
  endtask
  initial begin
    #1 x=3; y=0; a=200; b=100; s=8'h12; t=8'h34;
    src[0]=5; src[1]=6;
    proc[1:2] = '{4'd1,4'd2};
    #1;
    check_values(3);
    check("scalar",scalar[1] === 0 && scalar[2] === 1);
    check("struct",structs[1] === 8'h12 && structs[2] === 8'h34);
    check("width",wide[1] === 9'd300 && wide[2] === 1);
    check("xz",xz[1] === 4'b10xz && xz[2] === 4'bz01x);
    check("procedural control",proc[1] === 1 && proc[2] === 2);
    check("array control",copy[1] === 5 && copy[2] === 6);
    #2 x=7; y=1; s=8'hab; src[0]=9;
    #1;
    check_values(7);
    check("struct update",structs[1] === 8'hab && structs[2] === 8'h34);
    check("array update",copy[1] === 9 && copy[2] === 6);
    // §10.6.2: force overrides the element and release restores its driver.
    #1 force w[1]=4'he;
    #1 check("force",w[1] === 4'he && w[2] === 8);
    #1 release w[1];
    #1 check("release",w[1] === 7 && w[2] === 8);
    $display("PASS continuous slice patterns");
    $finish;
  end
endmodule
