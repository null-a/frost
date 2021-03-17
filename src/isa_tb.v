`default_nettype none
`timescale 1ns/1ps

module isa_tb;

   // http://fpgacpu.ca/fpga/Simulation_Clock.html
   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   integer cycle = 0;

   always @(posedge clk) begin
      cycle = cycle + 1;
   end


   wire [29:0] addr;
   wire [31:0] rdata;
   wire [31:0] wdata;
   wire re;
   wire we;

   cpu cpu (.clk(clk),
            .addr(addr), .wdata(wdata), .rdata(rdata),
            .re(re), .we(we));

   ram ram (.clk(clk), .addr(addr),
            .din(wdata), .dout(rdata),
            .re(re), .we(we));

   initial begin
      $readmemh({"../tests/", `ISA_TEST, ".hex"}, ram.ram);

      `ifdef SIM
      // $dumpfile("isa.vcd");
      // $dumpvars(0, cpu_tb);
      // $dumpvars(1, cpu.reg_file.file1[0]);
      // $dumpvars(1, cpu.reg_file.file1[1]);
      // $dumpvars(1, cpu.reg_file.file1[2]);
      // $dumpvars(1, cpu.reg_file.file1[3]);
      // $dumpvars(1, cpu.reg_file.file1[4]);
      // $dumpvars(1, cpu.reg_file.file1[28]);
      // $dumpvars(1, cpu.reg_file.file1[31]);
      `endif

      wait (cpu.halt == 1 || cycle == 10_000) #20;
      $display("test=%6s cycle=%d, halt=%d, pc=%d, x28=%d, result=%s",
               `ISA_TEST,
               cycle, cpu.halt, cpu.pc,
               cpu.reg_file.file1[28],
               cpu.reg_file.file1[31] ==
               32'h55 ? "pass" :
               32'haa ? "fail" : "error");
      $finish;
   end

endmodule // cpu_tb
