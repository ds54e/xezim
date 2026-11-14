// §26.3 and §9.2.2.2: qualified array readers and writers track the
// package's cells, including the driver re-evaluation on release (§10.6.2).
package other; int a[0:1]; wire [7:0] w[0:1]; wire [7:0] equal_net[0:1]; endpackage
module top;
  int a[0:1]; wire [7:0] w[0:1]; wire [7:0] equal_net[0:1];
  int ca, star, comb;
  assign ca=other::a[1];
  always @* star=other::a[1];
  always_comb comb=other::a[1];
  assign w[1]=8'd6;
  assign other::w[1]=8'd38;
  assign equal_net[1]=8'd6; assign other::equal_net[1]=8'd6;
  task check(input string label, input bit ok);
    if (ok) $display("PASS %s",label); else $display("FAIL %s",label);
  endtask
  initial begin
    #1 a[1]=6; other::a[1]=38;
    #1;
    check("package continuous dependency",ca === 38);
    check("package star dependency",star === 38);
    check("package comb dependency",comb === 38);
    a[1]=8; other::a[1]=48;
    #1;
    check("package updated dependencies",ca === 48 && star === 48 && comb === 48);
    force w[1]=9;
    #1;
    check("local force isolation",w[1] === 9 && other::w[1] === 38);
    release w[1];
    #1;
    check("local release isolation",w[1] === 6 && other::w[1] === 38);
    force other::w[1]=42;
    #1;
    check("package force isolation",w[1] === 6 && other::w[1] === 42);
    release other::w[1];
    #1;
    check("package release driver",w[1] === 6 && other::w[1] === 38);
    force other::equal_net[1]=42;
    #1 release other::equal_net[1];
    #1 check("equal net release guard",equal_net[1] === 6 && other::equal_net[1] === 6);
    $finish;
  end
endmodule
