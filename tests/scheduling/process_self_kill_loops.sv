// IEEE 1800-2023 §9.7: kill ends the executing process, including loop
// bodies (§12.7). Delayed forever iterations keep the unfixed case finite.
`timescale 1ns/1ps
module top;
  int a[1];
  int x_for, after_for; process p_for;
  int x_while, after_while; process p_while;
  int x_do, after_do; process p_do;
  int x_repeat, after_repeat; process p_repeat;
  int x_foreach, after_foreach; process p_foreach;
  int x_forever, after_forever; process p_forever;
  initial begin p_for = process::self(); for (int i=0; i<2; i++) begin x_for++; p_for.kill(); x_for = 100; end after_for = 1; end
  initial begin p_while = process::self(); while (x_while < 2) begin x_while++; p_while.kill(); x_while = 100; end after_while = 1; end
  initial begin p_do = process::self(); do begin x_do++; p_do.kill(); x_do = 100; end while (x_do < 2); after_do = 1; end
  initial begin p_repeat = process::self(); repeat (2) begin x_repeat++; p_repeat.kill(); x_repeat = 100; end after_repeat = 1; end
  initial begin p_foreach = process::self(); foreach (a[i]) begin x_foreach++; p_foreach.kill(); x_foreach = 100; end after_foreach = 1; end
  initial begin p_forever = process::self(); forever begin #1; begin x_forever++; p_forever.kill(); x_forever = 100; end end after_forever = 1; end
  initial begin #10;
    if (x_for == 1 && after_for == 0 && p_for.status() == process::KILLED) $display("PASS for"); else $display("FAIL for");
    if (x_while == 1 && after_while == 0 && p_while.status() == process::KILLED) $display("PASS while"); else $display("FAIL while");
    if (x_do == 1 && after_do == 0 && p_do.status() == process::KILLED) $display("PASS do"); else $display("FAIL do");
    if (x_repeat == 1 && after_repeat == 0 && p_repeat.status() == process::KILLED) $display("PASS repeat"); else $display("FAIL repeat");
    if (x_foreach == 1 && after_foreach == 0 && p_foreach.status() == process::KILLED) $display("PASS foreach"); else $display("FAIL foreach");
    if (x_forever == 1 && after_forever == 0 && p_forever.status() == process::KILLED) $display("PASS forever"); else $display("FAIL forever");
    $finish;
  end
endmodule
