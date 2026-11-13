// IEEE 1800-2023 §9.7: killing another process lets the caller continue;
// await waits for normal or forceful termination; suspend/resume preserves
// the continuation. §9.6.2: disable of a block/task and disable fork.
// Activity ends at t=4, and the observer samples at t=10 (§4.7).
`timescale 1ns/1ps
class ordinary;
  int x;
  function void kill(); x++; endfunction
  function void run(); kill(); x++; endfunction
endclass
module top;
  ordinary obj;
  process target, sleeper, normal_p, dead_p;
  int target_x, caller_x, suspend_x, suspended_seen, normal_x, await_x, killed_await_x;
  int block_x, task_x, fork_x, after_fork;
  task automatic early;
    task_x = 1;
    disable early;
    task_x = 2;
  endtask
  initial begin obj = new; obj.run(); end
  initial begin
    fork begin target = process::self(); #4; target_x = 1; end join_none
    #1; target.kill(); caller_x = 1;
  end
  initial begin
    fork begin sleeper = process::self(); #4; suspend_x = 1; end join_none
    #1; sleeper.suspend();
    #1; if (sleeper.status() == process::SUSPENDED) suspended_seen = 1;
    sleeper.resume();
  end
  initial begin
    fork begin normal_p = process::self(); #2; normal_x = 1; end join_none
    #1; normal_p.await(); await_x = 1;
    normal_p.await(); await_x++;
  end
  initial begin
    fork begin dead_p = process::self(); #1; dead_p.kill(); end join_none
    #0; dead_p.await(); killed_await_x = 1;
  end
  initial begin
    begin : early_block
      block_x = 1; disable early_block; block_x = 2;
    end
    block_x++;
    early(); task_x++;
    fork begin #4; fork_x = 1; end join_none
    #1; disable fork; after_fork = 1;
  end
  task automatic check(input bit good, input string tag);
    if (good) $display("PASS %s", tag); else $display("FAIL %s", tag);
  endtask
  initial begin
    #10;
    check(obj.x == 2, "ordinary_kill_method");
    check(target_x == 0 && caller_x == 1 && target.status() == process::KILLED, "kill_other");
    check(suspended_seen == 1 && suspend_x == 1 && sleeper.status() == process::FINISHED, "suspend_resume");
    check(normal_x == 1 && await_x == 2 && normal_p.status() == process::FINISHED, "await_finished");
    check(killed_await_x == 1 && dead_p.status() == process::KILLED, "await_killed");
    check(block_x == 2 && task_x == 2 && fork_x == 0 && after_fork == 1, "disable");
    $finish;
  end
endmodule
