`default_nettype none

module control(input clk,
               input [6:0] opcode,
               input [2:0] funct3,
               input bit30,
               input cmp_out,
               output reg [1:0] step,
               output halt,
               output pc_enable,
               output pc_load,
               output reg_re1,
               output reg_re2,
               output reg_we,
               output reg alu_sel1,
               output reg alu_sel2,
               output reg [4:0] alu_op,
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

   assign target_load = (step == 1);

   always @(*) begin
      casez ({step, opcode})
        {2'b01, 7'b?}:
          begin
             alu_sel1 = 1; alu_sel2 = 1;
          end
        {2'b11, OP_IMM},
        {2'b11, LUI}:
          begin
             alu_sel1 = 0; alu_sel2 = 1;
          end
        default:
          begin
             alu_sel1 = 0; alu_sel2 = 0;
          end
      endcase // casez ({step, opcode})
   end

   always @(*) begin
      casez ({step, opcode, funct3})
        {2'b11, OP,     3'b?}: alu_op = {1'b0, bit30, funct3};
        {2'b11, OP_IMM, 3'b?}: alu_op = {1'b0, 1'b0,  funct3};
        {2'b11, BRANCH, 3'b?}: alu_op = {1'b1, 1'b0,  funct3};
        default:               alu_op = {1'b0, 1'b0,  3'b0};
      endcase // casez ({step, opcode, funct3})
   end

endmodule // control
