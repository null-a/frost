`default_nettype none

module fpga (input CLK,
             input PIN_20,  // rx
             output PIN_21, // tx
             output LED,
             output USBPU);

   wire clk;
   assign clk = CLK;

   // Drive USB pull-up resistor low so that we don't look like a USB
   // device.
   assign USBPU = 0;

   reg [5:0] ready_counter = 0;
   wire ready = &ready_counter;
   always @(posedge clk) begin
      if (~ready) begin
         ready_counter <= ready_counter + 1;
      end
   end

   // Clean-up async rx input to avoid meta-stability.
   // TODO: This probably ought to have (at least) a second DFF.
   reg rx = 0;
   always @(posedge clk)
     rx <= PIN_20;

   top top (.clk(clk), .reset(~ready),
            .rx(rx), .tx(PIN_21),
            .out(LED));

endmodule // fpga
