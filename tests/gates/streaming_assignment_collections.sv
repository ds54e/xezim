`timescale 1ns/1ps
// IEEE 1800-2023 §11.4.14, §7.4/§7.5/§7.10: stream elements in order.
module top;
  byte fixed_bytes[2];
  byte dynamic_bytes[];
  byte queue_bytes[$];
  logic [31:0] fixed_value, dynamic_value, queue_value;
  logic [7:0] unpacked_bytes[4];
  byte unpacked_dynamic[];
  logic [31:0] repacked;
  initial begin
    fixed_bytes[0] = 8'h12; fixed_bytes[1] = 8'h34;
    dynamic_bytes = new[2]; dynamic_bytes[0] = 8'h56; dynamic_bytes[1] = 8'h78;
    queue_bytes.push_back(8'h9a); queue_bytes.push_back(8'hbc);
    fixed_value = {>>{fixed_bytes}};
    dynamic_value = {<<8{dynamic_bytes}};
    queue_value = {>>{queue_bytes}};
    // §11.4.14.3: unpacking remains a separate path.
    {>>{unpacked_bytes}} = 32'h12345678;
    unpacked_dynamic = new[4];
    {>>{unpacked_dynamic}} = 32'h11223344;
    repacked = {>>{unpacked_dynamic}};
    #1;
    $display("fixed=%h dynamic=%h queue=%h", fixed_value, dynamic_value, queue_value);
    $display("unpack=%h,%h,%h,%h dynamic_unpack=%h,%h repack=%h", unpacked_bytes[0], unpacked_bytes[1], unpacked_bytes[2], unpacked_bytes[3], unpacked_dynamic[0], unpacked_dynamic[3], repacked);
    $finish;
  end
endmodule
