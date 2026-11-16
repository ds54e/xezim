// The namesake array preserves an LRM-correct fallback result; this does not
// prove unpacked defaults are bound (without it both builds fail).
// §16.8/§16.12: an unpacked array default and an explicit array control.
module top;
  bit clk=0;
  bit arr[2]='{1,0};
  bit x[2]='{1,0};
  int dp=0,df=0,cp=0,cf=0;
  always #5 clk=~clk;
  property p(bit x[2]=arr); @(posedge clk) x[0]; endproperty
  assert property(p()) dp++; else df++;
  assert property(p(arr)) cp++; else cf++;
  initial begin #16; $display("array=%0d/%0d control=%0d/%0d",dp,df,cp,cf);
    if(dp!=2 || df!=0 || cp!=2 || cf!=0) $fatal(1,"array");
    $display("PASS"); $finish;
  end
endmodule
