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

   // 0:	00200093          	li	x1,2
   // 4:	00300113          	li	x2,3
   // 8:	001101b3          	add	x3,x2,x1
   // c:	00100073          	ebreak

   initial begin
      // ram[0] = 32'h00200093;
      // ram[1] = 32'h00300113;
      // ram[2] = 32'h001101b3;
      // ram[3] = 32'h00100073;
      $readmemh(`ifdef SIM "ram.hex" `else "tmp.hex" `endif, ram);
   end

   // Left word is address 0 to avoid this warning:
   // https://github.com/steveicarus/iverilog/issues/343
   reg [31:0] ram [0:2048-1];

   always @(posedge clk) begin
      if (re) begin
         dout <= ram[addr[10:0]];
      end
      if (we) begin
         ram[addr[10:0]] <= din;
      end
   end

endmodule // ram
