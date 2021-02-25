`default_nettype none

module control(input clk,
               input [6:0] opcode,
               input cmp_out,
               output reg [1:0] step,
               output halt,
               output pc_enable,
               output pc_load,
               output reg_re1,
               output reg_re2,
               output reg_we,
               output alu_sel1,
               output alu_sel2,
               output [2:0] alu_op,
               output target_load);

   localparam OP_IMM = 7'b0010011;
   localparam OP     = 7'b0110011;
   localparam SYSTEM = 7'b1110011;
   localparam BRANCH = 7'b1100011;
   localparam LUI    = 7'b0110111;

   initial begin
      step = 0;
   end

   wire [1:0] next_step;

   assign next_step = step + 1;

   always @(posedge clk) begin
      step <= next_step;
   end

   assign halt = opcode == SYSTEM;
   assign pc_enable = step == 3 && !halt;
   assign pc_load = step == 3 && (opcode == BRANCH && cmp_out);

   assign reg_re1 = step == 1;
   assign reg_re2 = step == 1;
   assign reg_we = step == 3 && (opcode == OP_IMM || opcode == OP || opcode == LUI);

   assign alu_sel1 = step == 1;
   assign alu_sel2 = step == 1 || opcode == OP_IMM || opcode == LUI;
   assign alu_op = step == 3 && opcode == BRANCH ? 3'b1 : 3'b0;

   assign target_load = (step == 1);

endmodule // control
