`default_nettype none

module ram(input clk,
           input [29:0] addr,
           input [31:0] din,
           input re,
           input we,
           output reg [31:0] dout);

   initial begin
      dout = 0;
   end

   initial begin
      ram[0] = 32'hff0000aa;
      ram[1] = 32'hff0000bb;
      ram[2] = 32'hff0000cc;
      ram[3] = 32'hff0000dd;
   end

   reg [31:0] ram [1024-1:0];

   always @(posedge clk) begin
      if (re) begin
         dout <= ram[addr[9:0]];
      end
   end

endmodule // ram
