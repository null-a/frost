`default_nettype none

module program_counter(input clk,
                       input reset,
                       input en,
                       input load,
                       input [31:0] target,
                       output reg [31:0] pc,
                       output [31:0] pc_plus_4);

   initial begin
      pc = 0;
   end

   wire [31:0] next_pc;

   assign pc_plus_4 = pc + 4;
   assign next_pc = load ? target : pc_plus_4;

   always @(posedge clk) begin
      if (reset) begin
         pc <= 0;
      end
      else if (en) begin
         pc <= next_pc;
      end
   end

endmodule // program_counter
