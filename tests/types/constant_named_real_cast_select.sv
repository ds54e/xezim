`timescale 1ns/1ps
// IEEE 1800-2023 §6.24.1 / §6.12.1, §20.5, §11.5.1, §20.6.2:
// an indexed part-select width is a positive constant integral expression.
module top;
  typedef int I;
  logic [7:0] data;
  initial begin
    if ($bits(data[0 +: $rtoi(I'(3.5))]) == 4)
      $display("PASS select");
    else $display("FAIL select");
    $finish;
  end
endmodule
