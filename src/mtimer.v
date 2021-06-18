`default_nettype none

module mtimer(input clk,
              input [31:0] din,
              input we,
              input [1:0] addr,
              output irq,
              output reg [31:0] dout);

   reg [3:0] count = 0;
   reg [63:0] mtime = 0;
   reg [63:0] mtimecmp = 0;

   assign irq = mtime >= mtimecmp;

   always @(posedge clk) begin
      count <= count + 1;
      if (&count)
        mtime <= mtime + 1;
   end

   always @(posedge clk) begin
      if (we) begin
         if (addr == 2'b10)
           mtimecmp[31:0] <= din;
         else if (addr == 2'b11)
           mtimecmp[63:32] <= din;
      end
   end

   always @(*) begin
      case (addr)
        2'b00: dout = mtime[31:0];
        2'b01: dout = mtime[63:32];
        2'b10: dout = mtimecmp[31:0];
        2'b11: dout = mtimecmp[63:32];
      endcase // case (addr)
   end

endmodule // mtimer
