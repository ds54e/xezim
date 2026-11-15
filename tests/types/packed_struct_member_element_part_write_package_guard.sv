// IEEE 1800-2023 §7.2.1, §7.4.1, §10.4.1, §11.5.1, §23.9, §26.3.
package pkg;
  typedef struct packed { logic [1:0][7:0] x; } t;
  t [1:0] a;
endpackage
interface bus;
  pkg::t [1:0] a;
  initial begin a='0; a[1].x[0][5:2]=4'ha; end
endinterface
module child(output logic [7:0] got);
  pkg::t [1:0] a;
  initial begin a='0; a[1].x[0][5:2]=4'ha; got=a[1].x[0]; end
endmodule
module top;
  pkg::t [1:0] a;
  bus b();
  logic [7:0] got;
  child c(got);
  for (genvar g=0; g<2; g++) begin: gen
    pkg::t [1:0] a;
    initial begin a='0; a[1].x[0][5:2]=4'ha; end
  end
  initial begin
    a='0; a[1].x[0]=8'h00;
    pkg::a='0; pkg::a[1].x[0][5:2]=4'ha;
    #1;
    $display("CONTEXT child=%h interface=%h package=%h generate=%h parent=%h",got,b.a[1].x[0],pkg::a[1].x[0],gen[1].a[1].x[0],a);
    $finish;
  end
endmodule
