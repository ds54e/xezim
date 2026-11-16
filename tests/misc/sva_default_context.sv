// §16.8/§16.12: defaults use live declaration-scope signals and actuals
// retain widths, selects, sampled expressions and explicit overrides.
// §16.5.1/§16.9.3: a has default sampled value 1 from its initializer.
module top;
  bit clk=0, a=1;
  logic [3:0] v=4'b1010;
  int default_p=0, default_f=0, control_p=0, control_f=0;
  int past_p=0, past_f=0, override_p=0, override_f=0;
  int past_control_p=0, past_control_f=0;
  always #5 clk=~clk;
  property p(x=a && v[1]); @(posedge clk) x; endproperty
  property q(x=$past(a)); @(posedge clk) x; endproperty
  assert property(p()) default_p++; else default_f++;
  assert property(p(a && v[1])) control_p++; else control_f++;
  assert property(q()) past_p++; else past_f++;
  assert property(q($past(a))) past_control_p++; else past_control_f++;
  assert property(p(v[0])) override_p++; else override_f++;
  initial begin
    #10 a=0;
    #6;
    $display("live=%0d/%0d control=%0d/%0d past=%0d/%0d override=%0d/%0d",
      default_p,default_f,control_p,control_f,past_p,past_f,override_p,override_f);
    $display("past-control=%0d/%0d",past_control_p,past_control_f);
    if(past_control_p!=2 || past_control_f!=0) $fatal(1,"past control");
    if(default_p!=1 || default_f!=1 || control_p!=1 || control_f!=1 ||
       past_p!=2 || past_f!=0 || override_p!=0 || override_f!=2) $fatal(1,"context");
    $display("PASS"); $finish;
  end
endmodule
