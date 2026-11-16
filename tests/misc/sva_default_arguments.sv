// IEEE 1800-2023 §16.8, §16.8.1, §16.12, §16.12.7, §16.12.18,
// §16.14.1–§16.14.3.
// Defaults are substituted; explicit actuals override them. Signals are
// initialized before clock edges 5 and 15; counters checked at 16 (§4.7).
module top;
  bit clk=0, a=1, b=0, x=1;
  always #5 clk=~clk;
  property p(ante=a,cons=b); @(posedge clk) ante |-> cons; endproperty
  property t(bit x=1); @(posedge clk) x; endproperty
  property trunc(bit z=2); @(posedge clk) z; endproperty
  property inherit(bit z=1, w=2); @(posedge clk) z |-> w; endproperty
  property f(x=0); @(posedge clk) x; endproperty
  property same(y=x); @(posedge clk) y; endproperty
  property expr(x=({a,b} == 2'b10) && (4'shf < 0) && (1'bx === 1'bx));
    @(posedge clk) x;
  endproperty
  sequence s(x=(a & !b)); x; endsequence
  int typed_truncate_p=0, typed_truncate_f=0;
  typed_truncate_label: assert property (trunc()) typed_truncate_p++; else typed_truncate_f++;
  int typed_inherit_p=0, typed_inherit_f=0;
  typed_inherit_label: assert property (inherit()) typed_inherit_p++; else typed_inherit_f++;
  int omitted_p=0, omitted_f=0;
  omitted_label: assert property (p()) omitted_p++; else omitted_f++;
  int explicit_p=0, explicit_f=0;
  explicit_label: assert property (p(a,b)) explicit_p++; else explicit_f++;
  int partial_p=0, partial_f=0;
  partial_label: assert property (p(a)) partial_p++; else partial_f++;
  int empty_p=0, empty_f=0;
  empty_label: assert property (p(,b)) empty_p++; else empty_f++;
  int named_p=0, named_f=0;
  named_label: assert property (p(.cons(),.ante())) named_p++; else named_f++;
  int named_default_p=0, named_default_f=0;
  named_default_label: assert property (p(.cons())) named_default_p++; else named_default_f++;
  int bare_p=0, bare_f=0;
  bare_label: assert property (p) bare_p++; else bare_f++;
  int override_p=0, override_f=0;
  override_label: assert property (p(1,1)) override_p++; else override_f++;
  int typed_p=0, typed_f=0;
  typed_label: assert property (t()) typed_p++; else typed_f++;
  int false_default_p=0, false_default_f=0;
  false_default_label: assert property (f()) false_default_p++; else false_default_f++;
  int typed_override_p=0, typed_override_f=0;
  typed_override_label: assert property (t(0)) typed_override_p++; else typed_override_f++;
  int nested_p=0, nested_f=0;
  nested_label: assert property (@(posedge clk) s() |-> s()) nested_p++; else nested_f++;
  int sequence_bare_p=0, sequence_bare_f=0;
  sequence_bare_label: assert property (@(posedge clk) s) sequence_bare_p++; else sequence_bare_f++;
  // §16.8: LRM-correct guard for supplied named actuals, which this change declines.
  // Main also fails s(.x(1)); this does not demonstrate named binding.
  int sequence_named_p=0, sequence_named_f=0;
  sequence_named_label: assert property (@(posedge clk) s(.x(0))) sequence_named_p++; else sequence_named_f++;
  int assume_default_p=0, assume_default_f=0;
  assume_default_label: assume property (p()) assume_default_p++; else assume_default_f++;
  int assume_pass_p=0, assume_pass_f=0;
  assume_pass_label: assume property (t()) assume_pass_p++; else assume_pass_f++;
  int cover_default_p=0, cover_default_f=0;
  cover_default_label: cover property (t()) cover_default_p++;
  int cover_fail_p=0, cover_fail_f=0;
  cover_fail_label: cover property (p()) cover_fail_p++;
  int scope_p=0, scope_f=0;
  scope_label: assert property (same()) scope_p++; else scope_f++;
  int expression_p=0, expression_f=0;
  expression_label: assert property (expr()) expression_p++; else expression_f++;
  initial begin
    #16;
    $display("typed_truncate=%0d/%0d", typed_truncate_p, typed_truncate_f);
    $display("typed_inherit=%0d/%0d", typed_inherit_p, typed_inherit_f);
    $display("omitted=%0d/%0d", omitted_p, omitted_f);
    $display("explicit=%0d/%0d", explicit_p, explicit_f);
    $display("partial=%0d/%0d", partial_p, partial_f);
    $display("empty=%0d/%0d", empty_p, empty_f);
    $display("named=%0d/%0d", named_p, named_f);
    $display("named_default=%0d/%0d", named_default_p, named_default_f);
    $display("bare=%0d/%0d", bare_p, bare_f);
    $display("override=%0d/%0d", override_p, override_f);
    $display("typed=%0d/%0d", typed_p, typed_f);
    $display("false_default=%0d/%0d", false_default_p, false_default_f);
    $display("typed_override=%0d/%0d", typed_override_p, typed_override_f);
    $display("nested=%0d/%0d", nested_p, nested_f);
    $display("sequence_bare=%0d/%0d", sequence_bare_p, sequence_bare_f);
    $display("sequence_named=%0d/%0d", sequence_named_p, sequence_named_f);
    $display("assume_default=%0d/%0d", assume_default_p, assume_default_f);
    $display("assume_pass=%0d/%0d", assume_pass_p, assume_pass_f);
    $display("cover_default=%0d/%0d", cover_default_p, cover_default_f);
    $display("cover_fail=%0d/%0d", cover_fail_p, cover_fail_f);
    $display("scope=%0d/%0d", scope_p, scope_f);
    $display("expression=%0d/%0d", expression_p, expression_f);
    if (typed_truncate_p != 0 || typed_truncate_f != 2 || typed_inherit_p != 0 || typed_inherit_f != 2 || omitted_p != 0 || omitted_f != 2 || explicit_p != 0 || explicit_f != 2 || partial_p != 0 || partial_f != 2 || empty_p != 0 || empty_f != 2 || named_p != 0 || named_f != 2 || named_default_p != 0 || named_default_f != 2 || bare_p != 0 || bare_f != 2 || override_p != 2 || override_f != 0 || typed_p != 2 || typed_f != 0 || false_default_p != 0 || false_default_f != 2 || typed_override_p != 0 || typed_override_f != 2 || nested_p != 2 || nested_f != 0 || sequence_bare_p != 2 || sequence_bare_f != 0 || sequence_named_p != 0 || sequence_named_f != 2 || assume_default_p != 0 || assume_default_f != 2 || assume_pass_p != 2 || assume_pass_f != 0 || cover_default_p != 2 || cover_default_f != 0 || cover_fail_p != 0 || cover_fail_f != 0 || scope_p != 2 || scope_f != 0 || expression_p != 2 || expression_f != 0) $fatal(1,"counts");
    $display("PASS"); $finish;
  end
endmodule
