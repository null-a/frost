`default_nettype none

module top (input clk,
            input reset,
            output reg out);

   wire re;
   wire we;
   wire [29:0] addr;
   wire [31:0] rdata;
   wire [31:0] wdata;

   cpu cpu (.clk(clk), .reset(reset),
            .ram_addr(addr), .ram_wdata(wdata), .ram_rdata(rdata),
            .ram_re(re), .ram_we(we));

   ram ram (.clk(clk), .addr(addr),
            .din(wdata), .dout(rdata),
            .re(re), .we(we));

   // A 1 bit output register. Accessed via the low bit of memory
   // address 0x400. (Low two bits of address lines are implicit,
   // hence 0x100 below.)

   always @(posedge clk) begin
      if (addr[8:0] == 9'b100000000 & we) begin
         out <= wdata[0];
      end
   end

endmodule // top
