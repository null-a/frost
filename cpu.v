`default_nettype none

module cpu(input clk);

   wire [1:0] step;
   wire pc_enable;
   wire [31:0] pc;
   wire [31:0] inst;

   control control(.clk(clk), .step(step), .pc_enable(pc_enable));

   program_counter program_counter (.clk(clk), .en(pc_enable), .load(1'b0),
                                    .target(0), .pc(pc));

   ram ram (.clk(clk), .addr(pc[31:2]), .din(0),
            .re(1'b1), .we(1'b0), .dout(inst));

endmodule // cpu
