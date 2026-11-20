`timescale 1ns/1ps
module top;
  real x;
  realtime t;
  shortreal s;
  int n;
  bit enabled;
  localparam real LO = -2.5;
  parameter real HI = -1.5;

  // §19.5.1, §19.5.7: both endpoints are included, singletons use
  // numeric equality, and integer bounds on a real point convert to real.
  covergroup analog (input real upper);
    option.per_instance = 1;
    ranged: coverpoint x {
      bins lo = {[LO:upper + HI]};
      bins hi = {[1.5:2.5]};
      bins others = default;
    }
    exact: coverpoint t { bins b = {2.25, 3}; }
    single: coverpoint s { bins b = {1.25}; }
    casted: coverpoint (real'(n)) { bins b = {2.0}; }
    computed: coverpoint x + 0.5 iff (enabled) { bins b = {3.0}; }
    unbounded: coverpoint x {
      bins lo = {[$:-2.5]};
      bins hi = {[2.5:$]};
    }
    zero: coverpoint x { bins b = {0.0}; }
  endgroup
  analog a;

  task automatic sample_at(real r, realtime rt, shortreal sr, int i, bit en);
    #1;
    x = r; t = rt; s = sr; n = i; enabled = en;
    #1;
    a.sample();
    $display("bins %0.0f %0.0f %0.0f %0.0f %0.0f %0.0f %0.0f",
             a.ranged.get_inst_coverage(), a.exact.get_inst_coverage(),
             a.single.get_inst_coverage(), a.casted.get_inst_coverage(),
             a.computed.get_inst_coverage(), a.unbounded.get_inst_coverage(),
             a.zero.get_inst_coverage());
  endtask

  initial begin
    #1;
    a = new(0.0);
    sample_at(-2.75, 2.125, 1.5, 1, 1);
    sample_at(-2.5, 2.25, 1.25, 2, 1);
    sample_at(2.5, 0.0, 2.0, 0, 0);
    sample_at(2.5, 0.0, 2.0, 0, 1);
    sample_at(-0.0, 0.0, 2.0, 0, 1);
  end
endmodule
