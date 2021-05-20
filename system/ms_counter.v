`default_nettype none

module ms_counter(input clk,
                  output reg [31:0] out);

   // A micro-second counter. Assumes that clk runs at 16 MHz.

   initial out = 0;
   reg [3:0] tick_count = 0;

   always @(posedge clk) begin
      tick_count <= tick_count + 1;
      if (&tick_count) begin
         out <= out + 1;
      end
   end

endmodule // ms_counter
