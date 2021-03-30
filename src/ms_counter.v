`default_nettype none

module ms_counter(input clk,
                  output reg [31:0] out);

   initial out = 0;

   // TODO: Could use mod_m_counter here.

   // Millisecond counter. Assumes clock is 16 MHz.
   localparam TICK_COUNT_MAX = 14'd15999;

   reg [13:0] tick_count = 0;

   always @(posedge clk) begin
      if (tick_count == TICK_COUNT_MAX) begin
         tick_count <= 0;
         out <= out + 1;
      end
      else begin
         tick_count <= tick_count + 1;
      end
   end

endmodule // ms_counter
