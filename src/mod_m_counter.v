`default_nettype none

module mod_m_counter
  #(parameter
    N=4, // enough bits for the counter i.e. ceil(log_2 M)
    M=10 // counts from 0 to M-1
    )
   (input clk, reset,
    output max_tick,
    output [N-1:0] q
    );

   reg [N-1:0] r_reg;
   wire [N-1:0] r_next;

   always @(posedge clk) begin
      if (reset)
        r_reg <= 0;
      else
        r_reg <= r_next;
   end

   // next-state logic
   assign r_next = r_reg == (M-1) ? 0 : r_reg + 1;

   // output logic
   assign q = r_reg;
   assign max_tick = r_reg == (M-1) ? 1 : 0;

endmodule // mod_m_counter
