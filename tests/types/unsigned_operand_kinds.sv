// IEEE 1800-2023 §11.8.1/§11.8.2; declarations §6.11, §7.2/§7.3,
// casts §6.24.1, calls §13.4, package scope §26, hierarchy §23, interfaces §25.
package pk;
 localparam bit [7:0] U=8'h80;
 localparam bit signed [7:0] S=-1;
endpackage
interface ifc; bit [7:0] u; byte s; endinterface
module leaf; bit [7:0] u; byte s; endmodule
module top;
 typedef bit [7:0] u8_t;
 typedef struct { bit [7:0] u; byte s; } unp_t;
 typedef union packed { bit [7:0] u; byte s; } union_t;
 byte s; bit [7:0] u; unp_t unp;
 union_t un_u;
 ifc i0(); leaf lf();
 function automatic bit [7:0] fu(input bit [7:0] a); return a; endfunction

wire [63:0] pkg_left = s + pk::U;
wire [63:0] pkg_right = pk::U + s;
wire [63:0] pkg_signed = s + $signed(pk::U);
wire [63:0] pkg_unsigned = s + $unsigned(pk::U);
wire [63:0] pkg_concat = s + {pk::U};
wire [7:0] pkg_narrow = s + pk::U;
wire [63:0] pkg_choice = 1'b1 ? s : pk::U;
wire [63:0] call_left = s + fu(u);
wire [63:0] call_right = fu(u) + s;
wire [63:0] call_signed = s + $signed(fu(u));
wire [63:0] call_unsigned = s + $unsigned(fu(u));
wire [63:0] call_concat = s + {fu(u)};
wire [7:0] call_narrow = s + fu(u);
wire [63:0] call_choice = 1'b1 ? s : fu(u);
wire [63:0] unp_left = s + unp.u;
wire [63:0] unp_right = unp.u + s;
wire [63:0] unp_signed = s + $signed(unp.u);
wire [63:0] unp_unsigned = s + $unsigned(unp.u);
wire [63:0] unp_concat = s + {unp.u};
wire [7:0] unp_narrow = s + unp.u;
wire [63:0] unp_choice = 1'b1 ? s : unp.u;
wire [63:0] union_left = s + un_u.u;
wire [63:0] union_right = un_u.u + s;
wire [63:0] union_signed = s + $signed(un_u.u);
wire [63:0] union_unsigned = s + $unsigned(un_u.u);
wire [63:0] union_concat = s + {un_u.u};
wire [7:0] union_narrow = s + un_u.u;
wire [63:0] union_choice = 1'b1 ? s : un_u.u;
wire [63:0] cast_left = s + u8_t'(u);
wire [63:0] cast_right = u8_t'(u) + s;
wire [63:0] cast_signed = s + $signed(u8_t'(u));
wire [63:0] cast_unsigned = s + $unsigned(u8_t'(u));
wire [63:0] cast_concat = s + {u8_t'(u)};
wire [7:0] cast_narrow = s + u8_t'(u);
wire [63:0] cast_choice = 1'b1 ? s : u8_t'(u);
wire [63:0] iface_left = s + i0.u;
wire [63:0] iface_right = i0.u + s;
wire [63:0] iface_signed = s + $signed(i0.u);
wire [63:0] iface_unsigned = s + $unsigned(i0.u);
wire [63:0] iface_concat = s + {i0.u};
wire [7:0] iface_narrow = s + i0.u;
wire [63:0] iface_choice = 1'b1 ? s : i0.u;
wire [63:0] hier_left = s + lf.u;
wire [63:0] hier_right = lf.u + s;
wire [63:0] hier_signed = s + $signed(lf.u);
wire [63:0] hier_unsigned = s + $unsigned(lf.u);
wire [63:0] hier_concat = s + {lf.u};
wire [7:0] hier_narrow = s + lf.u;
wire [63:0] hier_choice = 1'b1 ? s : lf.u;
function automatic longint union_ctx(input byte v); return v + un_u.u; endfunction
wire [63:0] union_function = union_ctx(s);
longint proc_choice, fn_sum;
function automatic longint ctx(input byte v, input bit [7:0] x); return v+fu(x); endfunction
initial begin
s=-1; u=8'h80; unp.u=u; unp.s=s; un_u.u=u; i0.u=u; i0.s=s; lf.u=u; lf.s=s; 
#1;
proc_choice = 1'b1 ? s : u8_t'(u);
fn_sum = ctx(s,u);
$display("union_function=%h",union_function);
$display("proc_choice=%h",proc_choice);
$display("fn_sum=%h",fn_sum);
$display("pkg_left=%h",pkg_left);
$display("pkg_right=%h",pkg_right);
$display("pkg_signed=%h",pkg_signed);
$display("pkg_unsigned=%h",pkg_unsigned);
$display("pkg_concat=%h",pkg_concat);
$display("pkg_narrow=%h",pkg_narrow);
$display("pkg_choice=%h",pkg_choice);
$display("call_left=%h",call_left);
$display("call_right=%h",call_right);
$display("call_signed=%h",call_signed);
$display("call_unsigned=%h",call_unsigned);
$display("call_concat=%h",call_concat);
$display("call_narrow=%h",call_narrow);
$display("call_choice=%h",call_choice);
$display("unp_left=%h",unp_left);
$display("unp_right=%h",unp_right);
$display("unp_signed=%h",unp_signed);
$display("unp_unsigned=%h",unp_unsigned);
$display("unp_concat=%h",unp_concat);
$display("unp_narrow=%h",unp_narrow);
$display("unp_choice=%h",unp_choice);
$display("union_left=%h",union_left);
$display("union_right=%h",union_right);
$display("union_signed=%h",union_signed);
$display("union_unsigned=%h",union_unsigned);
$display("union_concat=%h",union_concat);
$display("union_narrow=%h",union_narrow);
$display("union_choice=%h",union_choice);
$display("cast_left=%h",cast_left);
$display("cast_right=%h",cast_right);
$display("cast_signed=%h",cast_signed);
$display("cast_unsigned=%h",cast_unsigned);
$display("cast_concat=%h",cast_concat);
$display("cast_narrow=%h",cast_narrow);
$display("cast_choice=%h",cast_choice);
$display("iface_left=%h",iface_left);
$display("iface_right=%h",iface_right);
$display("iface_signed=%h",iface_signed);
$display("iface_unsigned=%h",iface_unsigned);
$display("iface_concat=%h",iface_concat);
$display("iface_narrow=%h",iface_narrow);
$display("iface_choice=%h",iface_choice);
$display("hier_left=%h",hier_left);
$display("hier_right=%h",hier_right);
$display("hier_signed=%h",hier_signed);
$display("hier_unsigned=%h",hier_unsigned);
$display("hier_concat=%h",hier_concat);
$display("hier_narrow=%h",hier_narrow);
$display("hier_choice=%h",hier_choice);
$finish; end
endmodule
