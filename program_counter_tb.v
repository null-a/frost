`default_nettype none
`timescale 1ns/1ps

module program_counter_tb;

   // http://fpgacpu.ca/fpga/Simulation_Clock.html
   reg clk;

   always begin
      #10 clk = (clk === 1'b0);
   end

   reg en = 0;
   reg load = 0;
   reg [31:0] target = 32'hc0ffee;

   wire [31:0] pc;
   wire [31:0] pc_plus_4;

   program_counter dut (.clk(clk), .en(en), .load(load),
                        .target(target),
                        .pc(pc), .pc_plus_4(pc_plus_4));

   initial begin
      $dumpfile("program_counter.vcd");
      $dumpvars(0, program_counter_tb);

      #35 en = 1;
      #40 load = 1;
      #10 load = 0;

      #200 $finish;
   end

endmodule // program_counter_tb
