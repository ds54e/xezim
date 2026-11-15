// IEEE 1800-2023 §7.2.1, §7.4.1, §11.5.1: selected packed bits
// share their aggregate's storage. §10.4.1, §10.4.2, §11.4.1:
// selectors are evaluated once; NBA selectors are captured before update.
module lane #(parameter logic [3:0] D=0)(input logic clk,
            output logic [7:0] blocking_value, nba_value, whole_value);
  typedef struct packed {logic [1:0][7:0] x;} t;
  t [1:0] a, n, w;
  initial begin
    a='0; n='0; w='0;
    a[1].x[0][5:2]=D;
    w[1].x[0]={2'b0,D,2'b0};
    blocking_value=a[1].x[0]; whole_value=w[1].x[0];
  end
  always @(posedge clk) begin
    n[1].x[0][5:2] <= D;
  end
  assign nba_value=n[1].x[0];
endmodule
module unrelated;
  logic a;
endmodule
module top;
  typedef struct packed {logic [1:0][7:0] x;} t;
  t [3:0] a, n;
  t [1:0][1:0] deep;
  logic clk;
  logic [7:0] b0,b1,n0,n1,w0,w1;
  logic [63:0] nba_snapshot;
  int i,j,k,base,calls,errors;
  lane #(4'ha) u0(clk,b0,n0,w0);
  lane #(4'h5) u1(clk,b1,n1,w1);
  unrelated other();
  function automatic int next_index(); calls++; return calls; endfunction
  task automatic check(input string name, input bit ok);
    if (ok) $display("PASS %s",name);
    else begin $display("FAIL %s",name); errors++; end
  endtask
  initial begin
    clk=0; errors=0; a='0; n='0; deep='0;
    i=0; a[i++].x[0][5:2]=4'ha;
    check("root postincrement",i==1 && a==64'h0000000000000028);
    calls=0; a='0; a[next_index()].x[0][5:2]=4'h5;
    check("root call",calls==1 && a==64'h0000000000140000);
    i=0; deep[i++][1].x[0][5:2]=4'ha;
    check("two root indices",i==1 && deep==64'h0000000000280000);
    a='0; j=0; a[3].x[j++][5:2]=4'ha;
    check("member postincrement",j==1 && a==64'h0028000000000000);
    a='0; i=0; j=0; base=2;
    a[i++].x[j++][base+++:4]=4'ha;
    check("all selector levels",i==1 && j==1 && base==3 && a==64'h28);
    a='0; i=0; a[i++].x[0][5:2]+=4'h3;
    check("compound target",i==1 && a==64'h0c);
    // Independent ordinary controls already pass on main.
    a='0; i=0; a[i++].x[0]=8'h28;
    check("whole element capture",i==1 && a==64'h28);
    n='0; i=0; n[i++].x[0][5:2] <= 4'ha;
    calls=0; n[next_index()].x[1][5:2] <= 4'h5;
    n[2].x[0][5:2] <= 4'h3;
    #1;
    nba_snapshot=n;
    check("NBA root increment",i==1 && nba_snapshot[7:0]==8'h28);
    check("NBA root call",calls==1 && nba_snapshot[31:24]==8'h14);
    check("NBA scoped aggregate",nba_snapshot===64'h0000000c14000028);
    check("NBA instance isolation",u0.n===32'h0 && u1.n===32'h0);
    check("blocking instances",b0==8'h28 && b1==8'h14);
    check("whole instances",w0==8'h28 && w1==8'h14);
    clk=1; #1;
    check("NBA instances",n0==8'h28 && n1==8'h14);
    if (errors==0) $display("ALL PASS");
    else $fatal(1,"%0d errors",errors);
    $finish;
  end
endmodule
