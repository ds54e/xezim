// IEEE 1800-2023 §28.5 Table 28-4 and minimum rise/fall delay to x;
// §28.6 Table 28-5 disabled tristates drive z; §10.3 copies preserve z.
// §28.4 controlling inputs dominate z. §4.7/§6.8: no time-zero stimulus
// or sampling on a transition boundary.
`timescale 1ns/1ps
module top;
  logic i, en;
  wire plain, inv, slow, fast, reversed, multi0, multi1;
  wire tri_out0, tri_out1, ni0, ni1, copy0, copy1;
  wire az, oz, nz, rz;
  wire weak_mixed;
  // §28.12: a strong 1 overrides a weak x. Keep the existing explicit
  // strength path until primitive strengths are represented in lowering.
  buf (weak0,weak1) #(2,4) weak_b(weak_mixed, i);
  assign weak_mixed=1'b1;
  buf b(plain, i);
  not n(inv, i);
  buf #(2,4) s(slow, i);
  not #(2,4) f(fast, i);
  buf #(4,2) r(reversed, i);
  buf #(0,4) m(multi0, multi1, i);
  bufif1 #(2,4) t1(tri_out1, i, en);
  bufif0 #(2,4) t0(tri_out0, i, en);
  notif1 #(2,4) n1(ni1, i, en);
  notif0 #(2,4) n0(ni0, i, en);
  assign copy0=i;
  assign #(2,4) copy1=i;
  and #(2,4) a(az, i, 1'b0);
  or #(2,4) o(oz, i, 1'b1);
  nand #(2,4) na(nz, i, 1'b0);
  nor #(2,4) no(rz, i, 1'b1);
  initial begin
    #1 i=0; en=0;
    #9 i=1'bz;
    #0.5;
    if ({plain,inv,multi0,multi1} === 4'bxxxx) $display("PASS immediate");
    else $display("FAIL immediate=%b", {plain,inv,multi0,multi1});
    if ({slow,fast,reversed} === 3'b010) $display("PASS pending");
    else $display("FAIL pending=%b", {slow,fast,reversed});
    #2;
    if ({slow,fast,reversed} === 3'bxxx) $display("PASS min delay");
    else $display("FAIL min delay=%b", {slow,fast,reversed});
    #4;
    if ({tri_out0,tri_out1,ni0,ni1} === 4'bxzxz) $display("PASS enable0");
    else $display("FAIL enable0=%b", {tri_out0,tri_out1,ni0,ni1});
    if ({copy0,copy1} === 2'bzz) $display("PASS copies");
    else $display("FAIL copies=%b", {copy0,copy1});
    if (weak_mixed === 1'b1) $display("PASS explicit strength");
    else $display("FAIL explicit strength=%b", weak_mixed);
    if ({az,oz,nz,rz} === 4'b0110) $display("PASS controlling");
    else $display("FAIL controlling=%b", {az,oz,nz,rz});
    #3 en=1;
    #7;
    if ({tri_out0,tri_out1,ni0,ni1} === 4'bzxzx) $display("PASS enable1");
    else $display("FAIL enable1=%b", {tri_out0,tri_out1,ni0,ni1});
  end
endmodule
