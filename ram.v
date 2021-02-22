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

   // 0:	00200013          	li	x0,2
   // 4:	00300093          	li	x1,3
   // 8:	00008133          	add	x2,x1,x0
   // c:	00100073          	ebreak

   initial begin
      ram[0] = 32'h00200013;
      ram[1] = 32'h00300093;
      ram[2] = 32'h00008133;
      ram[3] = 32'h00100073;
   end

   reg [31:0] ram [1024-1:0];

   always @(posedge clk) begin
      if (re) begin
         dout <= ram[addr[9:0]];
      end
   end

endmodule // ram
