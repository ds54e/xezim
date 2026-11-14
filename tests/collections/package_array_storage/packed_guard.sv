// Equal values intentionally guard existing packed selection; they do not prove isolation.
// §7.4.1/§7.4.2 and §26.3: packed subelements inside fixed unpacked cells.
package other;
  logic [1:0][7:0] a[0:1];
  typedef struct packed { logic [1:0][7:0] lanes; } lane_t;
  lane_t s[0:1];
endpackage
module top;
  logic [1:0][7:0] a[0:1]; other::lane_t s[0:1];
  initial begin
    #1 a[1]=16'h1234; other::a[1]=16'h1234; s[1]=16'h1234; other::s[1]=16'h1234;
    #1 $display("OBS packed subselect local=%h/%h package=%h/%h",a[1][1],a[1][0],other::a[1][1],other::a[1][0]);
    if (a[1][1] === 8'h12 && a[1][0] === 8'h34 && other::a[1][1] === 8'h12 && other::a[1][0] === 8'h34) $display("PASS packed subselect guard");
    else $display("FAIL packed subselect guard");
    if (s[1].lanes[1] === 8'h12 && s[1].lanes[0] === 8'h34 && other::s[1].lanes[1] === 8'h12 && other::s[1].lanes[0] === 8'h34) $display("PASS packed struct member guard");
    else $display("FAIL packed struct member guard");
    $finish;
  end
endmodule
