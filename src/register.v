`default_nettype none

module register(input clk,
                input en,
                input [31:0] din,
                output reg [31:0] dout);

   initial begin
      dout = 0;
   end

   always @(posedge clk) begin
      if (en) begin
         dout <= din;
      end
   end

endmodule // register
