// IEEE 1800-2023 §7.4.2, §26.3: signed labels at every unpacked dimension.
package p; int m[-2:1][-3:0]; int n[-1:0][-2:0][-3:0]; endpackage
module top;
  int m[-2:1][-3:0]; int n[-1:0][-2:0][-3:0]; int i=-1, j=-2, k=-3; int x,y,z;
  assign x=p::m[i][j]; always_comb y=p::n[i][j][k]; assign z=p::n[-1][-2][-3];
  initial begin
    #1; n[i][j][k]=7; p::m[-1][-2]=37; p::n[-1][-2][-3]=38;
    #1;
    if(x===37 && y===38 && z===38 && m[i][j]===0 && n[i][j][k]===7)
      $display("PASS signed deep selects");
    else $display("FAIL signed deep selects %0d %0d %0d %0d %0d",x,y,z,m[i][j],n[i][j][k]);
    $finish;
  end
endmodule
