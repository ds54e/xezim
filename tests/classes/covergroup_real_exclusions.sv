`timescale 1ns/1ps
module top;
  real x;
  bit on;
  // §19.5.5–§19.5.6 and §19.11.1: ignored and illegal values remove
  // empty bins from the denominator. An illegal sample emits one error
  // and does not count for the overlapping ordinary bin.
  covergroup cg;
    option.per_instance = 1;
    cp: coverpoint x {
      bins masked = {[-1.5:0.25]};
      bins lo = {[0.0:2.5]};
      bins hi = {[4.0:5.0]} iff (on);
      ignore_bins none = {[-1.75:-0.5], [0.0:0.75]};
      illegal_bins bad = {[-0.5:0.0], 2.5};
      bins others = default;
    }
    // §19.5 and §19.5.3: a default bin is an explicit catch-all and
    // contributes no bins to the coverage computation.
    fallback: coverpoint x { bins other = default; }
  endgroup
  cg g;

  task automatic sample_at(real v, bit w);
    int hit, total;
    real pct, group_pct;
    #1;
    x = v; on = w;
    #1;
    g.sample();
    pct = g.cp.get_inst_coverage(hit, total);
    group_pct = g.get_inst_coverage();
    $display("cp %0.0f %0d/%0d, group %0.0f", pct, hit, total, group_pct);
  endtask

  initial begin
    int hit, total;
    real pct;
    #1;
    g = new;
    pct = g.fallback.get_inst_coverage(hit, total);
    $display("default before %0.0f %0d/%0d", pct, hit, total);
    sample_at(0.5, 1);
    sample_at(2.5, 1);
    sample_at(1.5, 1);
    sample_at(4.5, 0);
    sample_at(4.5, 1);
    pct = g.fallback.get_inst_coverage(hit, total);
    $display("default after %0.0f %0d/%0d", pct, hit, total);
  end
endmodule
