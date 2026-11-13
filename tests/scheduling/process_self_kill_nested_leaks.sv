// IEEE 1800-2023 §9.7: independently killed processes cannot unwind a live
// nested-scheduler caller (§18.17), or unrelated edge methods (§9.2.2, §13.4).
// The second killer runs after current_pid has named the first killed process.
// Observe at t=13.5, away from integer-time clock edges and the t=12 return (§4.7).
`timescale 1ns/1ps
module top;
  bit clk;
  int edges, returned;
  process first, second;
  class C;
    int value;
    function int set_value(int v); value = v; return v; endfunction
  endclass
  C obj = new;
  always #1 clk = ~clk;
  always @(posedge clk) begin
    void'(obj.set_value(1));
    edges++;
  end
  task automatic nested_wait();
    randsequence (m) m : a; a : { #12; }; endsequence
  endtask
  initial begin nested_wait(); returned = 1; end
  initial begin first = process::self(); #2; first.kill(); end
  initial begin second = process::self(); #4; second.kill(); end
  initial begin
    #13.5;
    if (edges == 7 && obj.value == 1) $display("PASS nested_edges");
    else $display("FAIL nested_edges edges=%0d", edges);
    if (returned == 1 && first.status() == process::KILLED && second.status() == process::KILLED)
      $display("PASS nested_return");
    else $display("FAIL nested_return");
    $finish;
  end
endmodule
