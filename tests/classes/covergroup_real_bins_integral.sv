`timescale 1ns/1ps
module top;
  bit [2:0] x;
  covergroup cg;
    option.per_instance = 1;
    mixed: coverpoint x { bins a = {2.0, [4.0:5.0]}; bins b = {1}; }
    filtered: coverpoint x { bins a[] = {[0:7]} with (item % 2 == 0); }
    pattern_cp: coverpoint x { wildcard bins a = {3'b1??}; }
    trans: coverpoint x { bins a = (2 => 4); }
    automatic_cp: coverpoint x;
  endgroup
  cg g;
  initial begin
    #1; g = new; x = 2;
    #1; g.sample();
    $display("guard a %0.0f %0.0f %0.0f %0.0f %0.1f",
      g.mixed.get_inst_coverage(), g.filtered.get_inst_coverage(), g.pattern_cp.get_inst_coverage(),
      g.trans.get_inst_coverage(), g.automatic_cp.get_inst_coverage());
    #1; x = 4;
    #1; g.sample();
    $display("guard b %0.0f %0.0f %0.0f %0.0f %0.1f",
      g.mixed.get_inst_coverage(), g.filtered.get_inst_coverage(), g.pattern_cp.get_inst_coverage(),
      g.trans.get_inst_coverage(), g.automatic_cp.get_inst_coverage());
  end
endmodule
