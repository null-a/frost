`default_nettype none
`timescale 1ns/1ps

module top_tb;

   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   integer cycle = 0;

   always @(posedge clk) begin
      cycle = cycle + 1;
   end

   wire led;

   top dut (.clk(clk), .out(led));

   always @(posedge led) $display("on @ %d", cycle);
   always @(negedge led) $display("off @ %d", cycle);

   initial begin
      $dumpfile("top.vcd");
      $dumpvars(0, top_tb);
      #1000;
      $finish;
   end

endmodule // top_tb
