`default_nettype none
`timescale 1ns/1ps

module top_tb;

   // http://fpgacpu.ca/fpga/Simulation_Clock.html
   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   wire [31:0] pc;
   wire [31:0] inst;

   program_counter program_counter (.clk(clk), .en(1'b1), .load(1'b0),
                                    .target(0), .pc(pc));

   ram ram (.clk(clk), .addr(pc[31:2]), .din(0),
            .re(1'b1), .we(1'b0), .dout(inst));


   initial begin
      $dumpfile("top.vcd");
      $dumpvars(0, top_tb);
      #200 $finish;
   end

endmodule // top_tb
