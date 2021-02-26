`default_nettype none

module reg_file(input clk,
                input [4:0] ra1,
                input [4:0] ra2,
                input [4:0] wa,
                input [31:0] din,
                input re1,
                input re2,
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
      // dout1 = 0;
      // dout2 = 0;
      for(i=0; i<32; i=i+1) begin
         file1[i] = 0;
         file2[i] = 0;
      end
   end

   reg [31:0] file1 [31:0];
   reg [31:0] file2 [31:0];

   // Read port 1
   always @(posedge clk) begin
      if (re1) begin
         dout1 <= file1[ra1];
      end
   end

   // Read port 2
   always @(posedge clk) begin
      if (re2) begin
         dout2 <= file2[ra2];
      end
   end

   // Write port

   // TODO: I'm curious what logic this zero check generates. Is there
   // a smarter way to implement the zero register?

   always @(posedge clk) begin
      if (we & wa != 0) begin
         file1[wa] <= din;
         file2[wa] <= din;
      end
   end

endmodule // reg_file
