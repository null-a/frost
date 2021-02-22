`default_nettype none

module control(input clk,
               input [6:0] opcode,
               output reg [1:0] step,
               output pc_enable,
               output reg_re1,
               output reg_re2,
               output reg_we);

   localparam OP_IMM = 7'b0010011;

   initial begin
      step = 0;
   end

   wire [1:0] next_step;

   assign next_step = step + 1;

   always @(posedge clk) begin
      step <= next_step;
   end

   assign pc_enable = step == 3;

   assign reg_re1 = step == 1;
   assign reg_re2 = step == 1;
   assign reg_we = step == 3 && opcode == OP_IMM;

endmodule // control
