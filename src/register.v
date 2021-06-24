`default_nettype none

module register
  #(parameter WIDTH=32)
   (input clk,
    input en,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout);

   initial begin
      dout = 0;
   end

   always @(posedge clk) begin
      if (en) begin
         dout <= din;
      end
   end

endmodule // register
