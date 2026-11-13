// IEEE 1800-2023 §9.7: self() identifies the executing process; kill()
// terminates it and its descendants. §9.3.2 defines the three join forms.
// Each observer samples at t=10, away from activity at t=0,1,4 (§4.7).
`timescale 1ns/1ps
class killer;
  int x;
  process p;
  function void stop(input process h);
    x = 1;
    h.kill();
    x = 2;
  endfunction
  task run();
    p = process::self();
    stop(p);
    x = 3;
  endtask
endclass
class delayed_killer extends killer;
  task run_delayed();
    p = process::self();
    #1;
    stop(p);
    x = 4;
  endtask
endclass
// Cross the default method tier to exercise VM-to-VM calls too.
class warm_killer;
  int x;
  process p;
  function void leaf(input bit stop);
    x++;
    if (stop) p.kill();
    x++;
  endfunction
  function void middle(input bit stop);
    leaf(stop);
    if (stop) x = 999;
  endfunction
  task run();
    p = process::self();
    repeat (1100) middle(0);
    middle(1);
    x = 1000;
  endtask
endclass
module top;
  int xi, xj, xa, xn, xt, xd, xf, xv, tree, child, grandchild;
  int jr, ar, nr, sibling, method_return, delayed_return;
  int always_x;
  process pi, pj, pa, pn, pt, pd, pf, pv, alias_p, parent_p, child_p, grandchild_p, always_p;
  warm_killer wk;
  int warm_return;
  killer k;
  delayed_killer dk;
  // §13.3, §13.4: a call executes within its caller's process.
  task automatic stop_task(input process h);
    h.kill();
    xt = 2;
  endtask
  task automatic delayed_task(input process h);
    #1;
    stop_task(h);
    xd = 2;
  endtask
  function automatic void stop_function(input process h);
    h.kill();
    xf = 2;
  endfunction
  initial begin pi = process::self(); xi = 1; pi.kill(); xi = 2; end
  initial begin
    fork begin pj = process::self(); xj = 1; pj.kill(); xj = 2; end join
    jr = 1;
  end
  initial begin
    fork
      begin pa = process::self(); #1; xa = 1; pa.kill(); xa = 2; end
      begin #4; sibling = 1; end
    join_any
    // Check eventual continuation at t=10, after the sibling finishes.
    // This does not test immediate join_any release by the killed child.
    ar = 1;
  end
  initial begin
    fork begin pn = process::self(); xn = 1; pn.kill(); xn = 2; end join_none
    nr = 1;
  end
  initial begin pt = process::self(); xt = 1; stop_task(pt); xt = 3; end
  initial begin pd = process::self(); xd = 1; delayed_task(pd); xd = 3; end
  initial begin pf = process::self(); xf = 1; stop_function(pf); xf = 3; end
  initial begin pv = process::self(); alias_p = pv; xv = 1; alias_p.kill(); xv = 2; end
  initial begin k = new; k.run(); method_return = 1; end
  initial begin wk = new; wk.run(); warm_return = 1; end
  initial begin dk = new; dk.run_delayed(); delayed_return = 1; end
  always begin #1; always_p = process::self(); always_x++; always_p.kill(); always_x = 100; end
  initial begin
    parent_p = process::self();
    fork
      begin child_p = process::self(); #4; child = 1; end
      begin
        fork begin grandchild_p = process::self(); #4; grandchild = 1; end join_none
        #4;
      end
    join_none
    #1;
    tree = 1;
    parent_p.kill();
    tree = 2;
  end
  task automatic check(input bit good, input string tag);
    if (good) $display("PASS %s", tag); else $display("FAIL %s", tag);
  endtask
  initial begin
    #10;
    check(xi == 1 && pi.status() == process::KILLED, "initial");
    check(xj == 1 && jr == 1 && pj.status() == process::KILLED, "join");
    check(xa == 1 && ar == 1 && sibling == 1 && pa.status() == process::KILLED, "join_any");
    check(xn == 1 && nr == 1 && pn.status() == process::KILLED, "join_none");
    check(xt == 1 && pt.status() == process::KILLED, "task");
    check(xd == 1 && pd.status() == process::KILLED, "delayed_task");
    check(xf == 1 && pf.status() == process::KILLED, "function");
    check(xv == 1 && alias_p.status() == process::KILLED, "alias");
    check(k.x == 1 && method_return == 0 && k.p.status() == process::KILLED, "method");
    check(dk.x == 1 && delayed_return == 0 && dk.p.status() == process::KILLED, "delayed_method");
    check(always_x == 1 && always_p.status() == process::KILLED, "always");
    check(wk.x == 2201 && warm_return == 0 && wk.p.status() == process::KILLED, "compiled_method");
    check(tree == 1 && parent_p.status() == process::KILLED, "parent_stop");
    check(child == 0 && grandchild == 0 && child_p.status() == process::KILLED
      && grandchild_p.status() == process::KILLED, "descendants");
    $finish;
  end
endmodule
