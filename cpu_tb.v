`default_nettype none
`timescale 1ns/1ps

module cpu_tb;

   // http://fpgacpu.ca/fpga/Simulation_Clock.html
   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   time cycle = 0;

   always @(posedge clk) begin
      cycle = cycle + 1;
   end

   cpu dut (.clk(clk));

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars(0, cpu_tb);
      $dumpvars(1, dut.reg_file.file1[0]);
      $dumpvars(1, dut.reg_file.file1[1]);
      $dumpvars(1, dut.reg_file.file1[2]);
      $dumpvars(1, dut.reg_file.file1[3]);

      wait (dut.halt == 1 || cycle == 1000) #20;
      $display("cycle=%d, halt=%d, pc=%d, x3=%d", cycle, dut.halt, dut.pc, dut.reg_file.file1[3]);
      $finish;
   end

endmodule // cpu_tb
