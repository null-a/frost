`default_nettype none

module fpga (input CLK,
             // input PIN_14,  // switch
             output PIN_6,  // led 0 (lsb)
             output PIN_7,
             output PIN_8,
             output PIN_9,
             output PIN_10,
             output PIN_11,
             output PIN_12,
             output PIN_13, // led 7 (msb)
             input PIN_20,  // rx
             output PIN_21, // tx
             output LED,
             output USBPU);

   wire clk;
   assign clk = CLK;

   // Drive USB pull-up resistor low so that we don't look like a USB
   // device.
   assign USBPU = 0;

   // reg out = 0;

   // always @(posedge clk) begin
   //    if (~PIN_20) // rx
   //      out <= 1;
   // end

   // assign LED = out; //  PIN_20;


   reg [5:0] ready_counter = 0;
   wire ready = &ready_counter;
   always @(posedge clk) begin
      if (~ready) begin
         ready_counter <= ready_counter + 1;
      end
   end

   top top (.clk(clk), .reset(~ready),
            .rx(PIN_20), .tx(PIN_21),
            .out(LED));

endmodule // fpga
