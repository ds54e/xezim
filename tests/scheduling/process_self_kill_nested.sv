// IEEE 1800-2023 §9.7: self-kill terminates only the target subtree.
// Another process waiting in a randsequence code block (§18.17) must
// survive the killing child serviced by its nested scheduler. Observe at
// t=12, away from activity at t=0,2,4,7,9 (§4.7).
`timescale 1ns/1ps
module nested_worker;
  process p;
  int woke, done, after_kill;
  task automatic sleeper();
    randsequence (m) m : a; a : { #2; }; endsequence
  endtask
  initial begin
    sleeper(); woke = 1;
    fork
      begin p = process::self(); p.kill(); sleeper(); after_kill = 1; end
    join_none
    #5; done = 1;
  end
endmodule
module top;
  nested_worker a(), b();
  initial begin #12;
    if (a.woke == 1 && a.done == 1 && b.woke == 1 && b.done == 1)
      $display("PASS nested_survivor");
    else $display("FAIL nested_survivor");
    if (a.after_kill == 0 && b.after_kill == 0 && a.p.status() == process::KILLED
      && b.p.status() == process::KILLED) $display("PASS nested_self_kill");
    else $display("FAIL nested_self_kill");
    $finish;
  end
endmodule
