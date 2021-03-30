`default_nettype none

module ram
  #(parameter NUM_WORDS=2048)
   (input clk,
    input [29:0] addr,
    input [31:0] din,
    input re,
    input [3:0] we,
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

   localparam WIDTH = $clog2(NUM_WORDS);
   wire [WIDTH-1:0] addr_lo = addr[WIDTH-1:0];

   // Left word is address 0 to avoid this warning:
   // https://github.com/steveicarus/iverilog/issues/343
   reg [31:0] ram [0:NUM_WORDS-1];

   integer i;
   initial begin
      for (i=0; i<NUM_WORDS; i++) begin
         ram[i] = 32'b0;
      end
      `ifndef ISA_TEST
      $readmemh("firmware.hex", ram);
      `endif
   end


   always @(posedge clk) begin
      if (re) begin
         dout <= ram[addr_lo];
      end
      if (we[0]) ram[addr_lo][7:0]   <= din[7:0];
      if (we[1]) ram[addr_lo][15:8]  <= din[15:8];
      if (we[2]) ram[addr_lo][23:16] <= din[23:16];
      if (we[3]) ram[addr_lo][31:24] <= din[31:24];
   end

endmodule // ram
