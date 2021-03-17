`default_nettype none
`timescale 1ns/1ps

module ram_tb;

   // http://fpgacpu.ca/fpga/Simulation_Clock.html
   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   reg [10:0] addr = 2;
   reg [31:0] din = 0;
   reg re = 0;
   reg we = 0;
   wire [31:0] dout;

   ram dut (.clk(clk), .addr(addr), .din(din),
            .re(re), .we(we), .dout(dout));

   initial begin
      $dumpfile("ram.vcd");
      $dumpvars(0, ram_tb);

      #35 re = 1;
      #10 re = 0;

      #200 $finish;
   end

endmodule // ram_tb
