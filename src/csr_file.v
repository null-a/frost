`default_nettype none

module csr_file(input clk,
                input irq,
                input mie_set,
                input mie_reset,
                input we,
                input [11:0] addr,
                input [31:0] din,
                output reg mie,
                output reg mtip,
                output reg [31:0] dout);

   initial begin
      mie = 0;
      mtip = 0;
   end

   reg [31:0] mepc = 32'b0; // saved pc

   `include "defs.inc"

   // Reads

   always @(*) begin
      case (addr)
        MSTATUS: dout = {28'b0, mie, 3'b0};
        MTVEC:   dout = 32'h2000; // 8 KBytes
        MIP:     dout = {24'b0, mtip, 7'b0};
        MEPC:    dout = mepc;
        default: dout = 32'b0;
      endcase // case (addr)
   end

   // Writes

   // `mtip` is specified as being read-only. It's cleared from
   // software by writing to memory mapped `mtimercmp`.
   always @(posedge clk)
     mtip <= irq;

   always @(posedge clk) begin
      if (mie_set)
        mie <= 1'b1;
      else if (mie_reset)
        mie <= 1'b0;
      else if (we & addr == MSTATUS)
        mie <= din[3]; // mstatus[3]
   end

   always @(posedge clk)
     if (we & addr == MEPC)
       mepc <= din;

endmodule // csr
