`default_nettype none

module ram(input clk,
           input [29:0] addr,
           input [31:0] din,
           input re,
           input we,
           output reg [31:0] dout);

   // Specifying an initial value as below prevent yosys inferring a
   // BRAM. This is a known issue:
   //
   // https://github.com/YosysHQ/yosys/issues/1088
   //
   // Defining the register internally and using an output wire
   // (rather than reg) might be a workaround.

   // initial begin
   //    dout = 0;
   // end

   `ifndef ISA_TEST
   initial $readmemh("firmware.hex", ram);
   `endif

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
