`default_nettype none

module mem(input [2:0] read_op,
           input [1:0] write_op,
           output re,
           output [3:0] we,
           input [31:0] rdata_in,
           input [31:0] wdata_in,
           output [31:0] rdata_out,
           output [31:0] wdata_out,
           input [31:0] addr_in,
           output [29:0] addr_out);

   // TODO: Fix duplication with control.v
   localparam LNONE = 3'b011;
   localparam SNONE = 2'b11;

   assign re = read_op != LNONE;
   assign we = write_op == SNONE ? 4'b0 : 4'b1111;

   assign rdata_out = rdata_in;
   assign wdata_out = wdata_in;

   assign addr_out = addr_in[31:2];

endmodule // mem
