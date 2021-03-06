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
   wire [3:0] we;

   cpu_simple cpu (.clk(clk), .reset(1'b0), .irq(1'b0),
                   .addr(addr), .wdata(wdata), .rdata(rdata),
                   .re(re), .we(we), .mem_ready(1'b1));

   ram #(.NUM_WORDS(2048)) ram (.clk(clk), .addr(addr),
                                .din(wdata), .dout(rdata),
                                .re(re), .we(we));

   initial begin
      $readmemh({"../tests/", `ISA_TEST, ".hex"}, ram.ram);

      // $dumpfile("isa.vcd");
      // $dumpvars(0, isa_tb);
      // $dumpvars(1, cpu.reg_file.file[0]);
      // $dumpvars(1, cpu.reg_file.file[1]);
      // $dumpvars(1, cpu.reg_file.file[2]);
      // $dumpvars(1, cpu.reg_file.file[3]);
      // $dumpvars(1, cpu.reg_file.file[4]);
      // $dumpvars(1, cpu.reg_file.file[28]);
      // $dumpvars(1, cpu.reg_file.file[31]);

      wait (cpu.cpu.halt == 1 || cycle == 10_000) #20;
      $display("test=%7s cycle=%d, halt=%d, pc=%d, x28=%d, result=%s",
               `ISA_TEST,
               cycle, cpu.cpu.halt, cpu.cpu.pc,
               cpu.cpu.reg_file.file[28],
               cpu.cpu.reg_file.file[31] ==
               32'h55 ? "pass" :
               32'haa ? "fail" : "error");
      $finish;
   end

endmodule // cpu_tb
