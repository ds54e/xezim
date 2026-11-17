// §29.8 / §28.16: UDP and gate #4 both propagate after 4ps in the cell.
`timescale 1ns/1ps
module top;
  reg a; wire u, g;
  delay_cell c(a, u, g);
  initial begin
    a = 0; #10 a = 1;
    #0.002 $display("U|library-before %b%b", u, g);
    #0.004 $display("U|library-after %b%b", u, g);
    $finish;
  end
endmodule
