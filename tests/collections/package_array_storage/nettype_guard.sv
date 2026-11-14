// §6.6.7 and §26.3: user-defined net arrays with/without a resolver.
package other;
  typedef logic [7:0] byte_t;
  function automatic byte_t resolve_sum(input byte_t values[]);
    byte_t result=0; foreach(values[i]) result+=values[i]; return result;
  endfunction
  nettype byte_t plain_t;
  nettype byte_t sum_t with resolve_sum;
  plain_t a[0:1]; sum_t b[0:1];
endpackage
module top;
  import other::*;
  plain_t a[0:1]; sum_t b[0:1];
  assign a='{0,6}; assign other::a='{0,38};
  assign b='{0,7}; assign other::b='{0,39};
  initial begin
    #2 $display("OBS nettypes plain=%0d/%0d resolved=%0d/%0d",a[1],other::a[1],b[1],other::b[1]);
    if (a[1] === 6) $display("PASS user nettype local"); else $display("FAIL user nettype local");
    if (b[1] === 7) $display("PASS resolved nettype local"); else $display("FAIL resolved nettype local");
    $finish;
  end
endmodule
