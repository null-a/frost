`default_nettype none

module reg_file(input clk,
                input [4:0] ra,
                input [4:0] wa,
                input [31:0] din,
                input re,
                input we,
                output reg [31:0] dout1,
                output reg [31:0] dout2);


   // Specifying an initial value as below prevent yosys inferring a
   // BRAM. This is a known issue:
   //
   // https://github.com/YosysHQ/yosys/issues/1088
   //
   // Defining the register internally and using an output wire
   // (rather than reg) might be a workaround.

   integer i;

   initial begin
      for(i=0; i<32; i=i+1) begin
         file[i] = 0;
      end
   end

   reg [31:0] file [31:0];

   // Read
   always @(posedge clk) begin
      if (re) begin
         dout1 <= file[ra];
         dout2 <= dout1;
      end
   end

   // Write
   always @(posedge clk) begin
      if (we & wa != 0) begin
         file[wa] <= din;
      end
   end

endmodule // reg_file
