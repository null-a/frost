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
      $dumpvars(1, dut.reg_file.file1[0]);
      $dumpvars(1, dut.reg_file.file1[1]);
      $dumpvars(1, dut.reg_file.file1[2]);
      $dumpvars(1, dut.reg_file.file1[3]);
      #300 $finish;
   end

endmodule // cpu_tb
