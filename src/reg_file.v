`default_nettype none

module reg_file(input clk,
                input [4:0] ra,
                input [4:0] wa,
                input [31:0] din,
                input re,
                input we,
                output reg [31:0] dout1,
                output reg [31:0] dout2);

   // Avoid defining an initial value for the output registers, as
   // doing so prevents yosys inferring a BRAM. (Is defining the
   // register internally and using an output wire a workaround?)
   //
   // https://github.com/YosysHQ/yosys/issues/1088
   //
   // initial begin
   //    dout1 = 0;
   //    dout2 = 0;
   // end

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
