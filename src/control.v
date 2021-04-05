`default_nettype none

module control(input clk,
               input reset,
               input [6:0] opcode,
               input [2:0] funct3,
               input bit20,
               input bit30,
               input cmp_out,
               output halt,
               output pc_enable,
               output pc_load,
               output reg_re,
               output reg_we,
               output reg_rs_sel,
               output reg alu_sel1,
               output reg alu_sel2,
               output reg [4:0] alu_op,
               output target_load,
               output [1:0] wd_sel,
               output mem_addr_sel,
               output [2:0] mem_read_op,
               output [1:0] mem_write_op,
               output inst_load);

   `include "defs.inc"

   localparam FETCH1  = 3'd0; // Load the instruction in RAM.
   localparam FETCH2  = 3'd1; // Transfer to instruction register.
   localparam DECODE1 = 3'd2; // Load first reg
   localparam DECODE2 = 3'd3; // Load second reg
   localparam MEM     = 3'd4;
   localparam EXEC    = 3'd5;

   reg [2:0] step;

   initial begin
      step = 0;
   end

   wire [2:0] next_step;

   assign next_step = step == 5 ? 0 : step + 1;

   always @(posedge clk) begin
      if (reset) begin
         step <= 0;
      end
      else begin
         step <= next_step;
      end
   end

   assign halt = opcode == SYSTEM && bit20;
   assign pc_enable = step == EXEC && !halt;
   assign pc_load = step == EXEC && ((opcode == BRANCH && cmp_out) || opcode == JAL || opcode == JALR);

   assign reg_re = (step == DECODE1) || (step == DECODE2);
   assign reg_rs_sel = step == DECODE1;

   assign reg_we = step == EXEC && (opcode == OP_IMM || opcode == LUI || opcode == OP ||
                                    opcode == AUIPC || opcode == JAL || opcode == JALR ||
                                    opcode == LOAD);

   assign wd_sel = (opcode == JAL || opcode == JALR) ? 2'b01 :
                   opcode == LOAD ? 2'b11 : 2'b00;

   assign mem_addr_sel = step == MEM;

   assign mem_read_op = step == FETCH1               ? LW :
                        step == MEM & opcode == LOAD ? funct3 :
                        /* otherwise */                LNONE;

   assign mem_write_op = step == MEM & opcode == STORE ? funct3[1:0] :
                         /* otherwise */                 SNONE;

   assign inst_load = step == FETCH2;

   assign target_load = step == DECODE2 || (step == MEM && opcode == JALR);

   always @(*) begin
      casez ({step, opcode})
        {DECODE1, 7'b?},
        {DECODE2, 7'b?},
        {EXEC,   AUIPC}:
          begin
             alu_sel1 = 1; alu_sel2 = 1;
          end
        {EXEC,   OP_IMM},
        {EXEC,   LUI},
        {MEM,    LOAD},
        {MEM,    STORE},
        {MEM,    JALR}:
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
        {EXEC, OP_IMM, 3'b101}: alu_op = {1'b0, bit30, funct3};
        {EXEC, OP,     3'b?}:   alu_op = {1'b0, bit30, funct3};
        {EXEC, OP_IMM, 3'b?}:   alu_op = {1'b0, 1'b0,  funct3};
        {EXEC, BRANCH, 3'b?}:   alu_op = {1'b1, 1'b0,  funct3};
        default:                alu_op = {1'b0, 1'b0,  3'b0};
      endcase // casez ({step, opcode, funct3})
   end

endmodule // control
