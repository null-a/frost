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
      `ifdef SIM
      $dumpfile("cpu.vcd");
      $dumpvars(0, cpu_tb);
      $dumpvars(1, dut.reg_file.file1[0]);
      $dumpvars(1, dut.reg_file.file1[1]);
      $dumpvars(1, dut.reg_file.file1[2]);
      $dumpvars(1, dut.reg_file.file1[3]);
      $dumpvars(1, dut.reg_file.file1[4]);
      $dumpvars(1, dut.reg_file.file1[28]);
      $dumpvars(1, dut.reg_file.file1[31]);
      `endif

      wait (dut.halt == 1 || cycle == 10_000) #20;
      $display("cycle=%d, halt=%d, pc=%d, x28=%d, result=%s",
               cycle, dut.halt, dut.pc,
               dut.reg_file.file1[28],
               dut.reg_file.file1[31] ==
               32'h55 ? "pass" :
               32'haa ? "fail" : "error");
      $finish;
   end

endmodule // cpu_tb
