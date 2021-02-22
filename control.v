`default_nettype none

module control(input clk,
               output reg [1:0] step,
               output pc_enable);

   initial begin
      step = 0;
   end

   wire [1:0] next_step;

   assign next_step = step + 1;

   always @(posedge clk) begin
      step <= next_step;
   end

   assign pc_enable = step == 3;

endmodule // control
