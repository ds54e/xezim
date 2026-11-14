// IEEE 1800-2023 §6.8, §7.4 and §26.3: storage retains the owner's
// width, two-state/four-state element type, bounds and typedef dimensions.
package other;
  logic [3:0] a[0:1]; bit [3:0] b[0:1];
  logic [7:0] different[0:1];
  typedef int row_t[2:1]; row_t typed;
  int negative[-1:1];
endpackage
module top;
  bit [3:0] a[0:1]; logic [3:0] b[0:1];
  logic [3:0] different[0:2]; other::row_t typed;
  int negative[-1:1]; int zero, one;
  assign zero=negative[0]; assign one=negative[1];
  task check(input string label, input bit ok);
    if (ok) $display("PASS %s", label); else $display("FAIL %s", label);
  endtask
  initial begin
    #1;
    check("own default types", a[1] === 4'b0 && other::a[1] === 4'bx && b[1] === 4'bx && other::b[1] === 4'b0);
    a[1]=4'b1010; other::a[1]=4'bx1z0;
    b[1]=4'bz0x1; other::b[1]=4'b0110;
    different[1]=4'ha; other::different[1]=8'hcd;
    typed[1]=7; other::typed[1]=39;
    negative[-1]=5; negative[0]=6; negative[1]=7;
    other::negative[-1]=37; other::negative[0]=38; other::negative[1]=39;
    #1;
    check("own four state package", a[1] === 4'b1010 && other::a[1] === 4'bx1z0);
    check("own four state module", b[1] === 4'bz0x1 && other::b[1] === 4'b0110);
    check("own widths", different[1] === 4'ha && other::different[1] === 8'hcd);
    check("descending typedef", typed[1] === 7 && other::typed[1] === 39);
    check("negative bounds zero", zero === 6 && other::negative[0] === 38);
    check("negative bounds one", one === 7 && other::negative[1] === 39);
    // §7.4.2: the existing negative constant-index continuous-read defect
    // is probed separately; these checks exercise storage and nonnegative labels.
    $finish;
  end
endmodule
