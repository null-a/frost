`default_nettype none
`timescale 1ns/1ps

module top_tb;

   reg clk;

   always begin
      #31.25 clk = (clk === 1'b0); // 16 MHz
   end

   integer cycle = 0;

   always @(posedge clk) begin
      cycle = cycle + 1;
   end

   wire tx;
   reg rx;
   reg reset;
   wire tx_done_tick;
   wire [7:0] tx_fifo_out;

   // TODO: Specifically load the expected (echo) firmware.

   top dut (.clk(clk), .reset(reset), .tx(tx), .rx(rx));

   // Capture the UART output directly from the buffer. This is easier
   // than reconstructing the output from the serial line, and is
   // sufficient for present purposes.
   always @(posedge clk) begin
      if (dut.uart.tx_done_tick) begin
         $write("%c", dut.uart.tx_fifo_out);
         $fflush();
      end
   end

   localparam sp = 52083.33; // serial period
   integer i;

   initial begin
      // $dumpfile("top.vcd");
      // $dumpvars(0, top_tb);
      $display("==========");
      rx = 1;
      reset = 1;
      #200;
      reset = 0;

      #sp;
      #sp;

      for (i=0; i<128; i=i+1) begin
         txchar("0");
      end

      txchar("\n"); txchar("d"); txchar("o"); txchar("n"); txchar("e");
      #800000;

      // This is useful with programs that terminate.
      // wait(dut.cpu.halt & dut.uart.tx_empty);

      $display("\n==========");
      $finish;
   end

   // I'd like to drive this with `fgetc` or similar, but that doesn't
   // work.
   // https://electronics.stackexchange.com/questions/387423/verilog-non-blocking-file-read
   task txchar (input integer c);
      begin
         rx = 0;             #sp; // start bit
         rx = (c & 1) > 0;   #sp; // data bits
         rx = (c & 2) > 0;   #sp;
         rx = (c & 4) > 0;   #sp;
         rx = (c & 8) > 0;   #sp;
         rx = (c & 16) > 0;  #sp;
         rx = (c & 32) > 0;  #sp;
         rx = (c & 64) > 0;  #sp;
         rx = (c & 128) > 0; #sp;
         rx = 1;             #sp; // stop bit
      end
   endtask // txchar

endmodule // top_tb
