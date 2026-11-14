//! IEEE 1800-2023 §26.3 and §37: source and artifact handles retain
//! package storage and canonical package full names.
use std::process::Command;

const READER: &str = r###"#include <string.h>
#include "vpi_user.h"
static void show(const char *s){
 vpiHandle h=vpi_handle_by_name((PLI_BYTE8*)s,0);
 if(!h){vpi_printf("OBS VPI %s NONE\n",s);return;}
 s_vpi_value v={.format=vpiIntVal}; vpi_get_value(h,&v);
 vpi_printf("OBS VPI %s value=%d type=%d full=%s\n",s,v.value.integer,vpi_get(vpiType,h),vpi_get_str(vpiFullName,h));
}
static PLI_INT32 readit(PLI_BYTE8*u){
 show("top.a[1]");show("p::a[1]");show("p.a[1]");
 show("p::m[1][0]");show("p.m[1][0]");show("p::n[1][0][1]");
 vpiHandle p=vpi_handle_by_name("p",0),a=vpi_handle_by_name("a",p),e=vpi_handle_by_index(a,1);
 vpi_printf("OBS VPI package-handle=%s\n",p?"present":"NONE");
 if(e){s_vpi_value v={.format=vpiIntVal};vpi_get_value(e,&v);vpi_printf("OBS VPI relative=%d\n",v.value.integer);}else vpi_printf("OBS VPI relative=NONE\n");
 return 0;
}
static void reg(void){s_vpi_systf_data d;memset(&d,0,sizeof d);d.type=vpiSysTask;d.tfname="$readit";d.calltf=readit;vpi_register_systf(&d);}
void (*vlog_startup_routines[])(void)={reg,0};
"###;
const SOURCE: &str = r###"package p; int a[0:1]; int m[2][2]; int n[2][2][2]; endpackage
module top; int a[0:1]; int m[2][2]; int n[2][2][2];
initial begin #1 a[1]=6; p::a[1]=38; p::m[1][0]=41; p::n[1][0][1]=42;
#1 $readit; $finish; end endmodule
"###;

#[test]
fn package_array_handles_in_source_and_artifacts() {
    let dir = std::env::temp_dir().join(format!("xezim_package_array_vpi_{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("reader.c"), READER).unwrap();
    std::fs::write(dir.join("top.sv"), SOURCE).unwrap();
    let cc = Command::new(std::env::var_os("CC").unwrap_or_else(|| "clang".into()))
        .args(["-shared", "-fPIC", "-I"])
        .arg(std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("include"))
        .args(["reader.c", "-o", "reader.so"])
        .current_dir(&dir)
        .status()
        .unwrap();
    assert!(cc.success());
    let run = |args: &[&str]| {
        let out = Command::new("bash")
            .args([
                "-c",
                "ulimit -v 4000000; exec timeout 60s \"$@\"",
                "vpi-test",
            ])
            .arg(env!("CARGO_BIN_EXE_xezim"))
            .args(args)
            .current_dir(&dir)
            .output()
            .unwrap();
        let text = format!(
            "{}{}",
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        );
        assert!(out.status.success(), "{text}");
        text
    };
    run(&["top.sv", "--compile", "--no-cache", "-o", "top.xezbc"]);
    for input in ["top.sv", "top.xezbc"] {
        let text = run(&[input, "--no-cache", "--vpi-lib", "./reader.so"]);
        for expected in [
            "OBS VPI top.a[1] value=6 type=612 full=top.a[1]",
            "OBS VPI p::a[1] value=38 type=612 full=p::a[1]",
            "OBS VPI p.a[1] value=38 type=612 full=p::a[1]",
            "OBS VPI p::m[1][0] value=41 type=612 full=p::m[1][0]",
            "OBS VPI p.m[1][0] value=41 type=612 full=p::m[1][0]",
            "OBS VPI p::n[1][0][1] value=42 type=612 full=p::n[1][0][1]",
            "OBS VPI package-handle=present",
            "OBS VPI relative=38",
        ] {
            assert!(text.contains(expected), "{input}: {text}");
        }
    }
    std::fs::remove_dir_all(dir).unwrap();
}
