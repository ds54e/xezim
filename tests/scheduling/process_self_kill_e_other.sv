// IEEE 1800-2023 §9.7: killing a process affects only its subtree.
// §9.2.3: final procedures execute at explicit or natural simulation end.
// §9.2.2, §9.4.2, §10.4.2, §12.7–12.8, §13.4: independent
// comb/edge bodies, NBA updates, loops, break and function calls continue.
// A clocked always kills ANOTHER process by an explicit handle. The always body is not that process:
// its remaining statements must run (LRM), as they do on main.
`timescale 1ns/1ps
module top;
  bit clk;
  int n, after_kill, drv_done, vic_x, after_kill2;
  process drv, victim;
  // case 1: the handle belongs to the process that drives the clock
  always @(posedge clk) begin
    n++;
    if (n == 2) begin
      drv.kill();
      after_kill = 1;
    end
  end
  initial begin
    drv = process::self();
    repeat (6) #1 clk = ~clk;
    drv_done = 1;
  end
  // case 2: the handle belongs to an unrelated sleeping process
  bit clk2;
  always @(posedge clk2) begin
    victim.kill();
    after_kill2 = 1;
  end
  initial begin victim = process::self(); #5; vic_x = 1; end
  initial begin #2; clk2 = 1; end
  initial begin
    #20;
    if (n == 2 && after_kill == 1 && drv_done == 0 && drv.status() == process::KILLED) $display("PASS kill_clock_driver");
    else $display("FAIL kill_clock_driver n=%0d after_kill=%0d drv_done=%0d st=%0d", n, after_kill, drv_done, drv.status());
    if (after_kill2 == 1 && vic_x == 0 && victim.status() == process::KILLED) $display("PASS kill_unrelated");
    else $display("FAIL kill_unrelated after_kill2=%0d vic_x=%0d st=%0d", after_kill2, vic_x, victim.status());
    $finish;
  end
endmodule
