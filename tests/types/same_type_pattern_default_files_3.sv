// IEEE 1800-2023 §§6.22.1(d), 10.9.2: packages declare distinct types.
module top;
  pa::S s;
  pb::P p;
  assign s = '{tag:7,default:p};
  initial begin
    p = 8'h12;
    #1;
    $display("T|cross_file %0d %h %h", s.tag, s.pk.a, s.pk.b);
    $finish;
  end
endmodule
