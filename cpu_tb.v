`default_nettype none
`timescale 1ns/1ps

module cpu_tb;

   // http://fpgacpu.ca/fpga/Simulation_Clock.html
   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   cpu dut (.clk(clk));

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars(0, cpu_tb);
      #300 $finish;
   end

endmodule // cpu_tb
