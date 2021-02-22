`default_nettype none

module fpga (input CLK,
             output LED,
             output USBPU);

   // Drive USB pull-up resistor low so that we don't look like a USB
   // device.
   assign USBPU = 0;

   // Turn on-board LED off.
   assign LED = 0;

   top top (.clk(CLK));

endmodule // fpga
