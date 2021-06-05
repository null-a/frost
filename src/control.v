`default_nettype none

module control(input clk,
               input reset,
               input [6:0] opcode,
               input [2:0] funct3,
               input bit20,
               input bit30,
               input cmp_out,
               output reg halt,
               output reg pc_load,
               output reg reg_re,
               output reg reg_we,
               output reg reg_rs_sel, // TODO: It would be better to call this `reg_ra_sel`?
               output reg alu_sel1,
               output reg [1:0] alu_sel2,
               output reg [4:0] alu_op,
               output reg reg_wd_sel,
               output reg mem_addr_sel,
               output reg [2:0] mem_read_op,
               output reg [1:0] mem_write_op,
               output reg inst_load,
               output reg alu_reg_load,
               output reg next_pc_sel);

   // Opportunities to optimise:

   // LUI
   // ===
   //
   // This is executed in a round about way. I do something like:
   //
   //   r1 <= x0 (This relies on a special case in `decode.v`.)
   //   alu_reg <= r1 + imm
   //   regfile[rd] <= alu_reg
   //
   // If I had an ALU op that passed through the `a` input unmodified,
   // I could use it here and dispense with the load of `x0`, saving a
   // cycle.
   //
   // More extreme, would be to wire `imm` directly to the mux in
   // front of the regfile `wd` input. This could potentially save two
   // cycles. As well as the cost of the wider mux, I'd need to check
   // this didn't lengthen the critical path. (It may not.)
   //
   // STORE
   // ====
   //
   // I think I could save a cycle by performing the load of r2 and
   // `alu_reg <= r1 + imm` in parallel. I don't do that at present
   // because the change entails loading r1 before r2, but the
   // register file interface forces r2 to be loaded before r1.

   `include "defs.inc"

   localparam STATE0         = 4'd0;
   localparam STATE1         = 4'd1;
   localparam STATE2         = 4'd2;
   localparam FETCH_REG      = 4'd3;
   localparam ALU_OP_IMM     = 4'd4;
   localparam ALU_OP         = 4'd5;
   localparam ALU_R1_ADD_IMM = 4'd6;
   localparam ALU_TO_RF      = 4'd7;
   localparam COND_BRANCH    = 4'd8;
   localparam JALR_ALU       = 4'd9;
   localparam MEM_WRITE      = 4'd10;
   localparam MEM_READ       = 4'd11;
   localparam MEM_TO_RF      = 4'd12;

   reg [3:0] state = STATE0, next_state;

   always @(posedge clk) begin
      if (reset)
        state <= STATE0;
      else
        state <= next_state;
   end

   localparam ANY = 7'b?;

   // Fields decoded from the instruction (opcode, funct3, imm, etc.)
   // are available from STATE2 and later.
   always @(*) begin
      casez ({state, opcode})
        {STATE0,         ANY}:      next_state = STATE1;
        {STATE1,         ANY}:      next_state = STATE2;
        {STATE2,         OP_IMM}:   next_state = ALU_OP_IMM;
        {STATE2,         OP}:       next_state = FETCH_REG;
        {STATE2,         LUI}:      next_state = ALU_R1_ADD_IMM;
        {STATE2,         AUIPC}:    next_state = ALU_TO_RF;
        {STATE2,         BRANCH}:   next_state = FETCH_REG;
        {STATE2,         JAL}:      next_state = STATE0;
        {STATE2,         JALR}:     next_state = JALR_ALU;
        {STATE2,         LOAD}:     next_state = ALU_R1_ADD_IMM;
        {STATE2,         STORE}:    next_state = FETCH_REG;
        {STATE2,         MISC_MEM}: next_state = STATE0;
        {STATE2,         SYSTEM}:   next_state = state; // Assuming `ebreak`.
        {FETCH_REG,      BRANCH}:   next_state = COND_BRANCH;
        {FETCH_REG,      OP}:       next_state = ALU_OP;
        {FETCH_REG,      STORE}:    next_state = ALU_R1_ADD_IMM;
        {ALU_OP_IMM,     ANY}:      next_state = ALU_TO_RF;
        {ALU_OP,         ANY}:      next_state = ALU_TO_RF;
        {ALU_R1_ADD_IMM, LUI}:      next_state = ALU_TO_RF;
        {ALU_R1_ADD_IMM, LOAD}:     next_state = MEM_READ;
        {ALU_R1_ADD_IMM, STORE}:    next_state = MEM_WRITE;
        {ALU_TO_RF,      ANY}:      next_state = STATE0;
        {COND_BRANCH,    ANY}:      next_state = STATE0;
        {JALR_ALU,       ANY}:      next_state = STATE0;
        {MEM_READ,       ANY}:      next_state = MEM_TO_RF;
        {MEM_WRITE,      ANY}:      next_state = STATE0;
        {MEM_TO_RF,      ANY}:      next_state = STATE0;
        default:                    next_state = state;
      endcase
   end

   always @(*) begin
      // Specify defaults for everything to avoid inferring latches.
      //
      // TODO: I think it will be possible to save a tiny number of
      // LUT here, by fiddling with the default value of control
      // signals that are "don't cares". e.g. mux select lines. Is
      // there a way to have the tools do this automatically? (Using
      // x/z/? doesn't appear to do what I want.)
      //
      // Maybe not as of 2018:
      // https://github.com/YosysHQ/yosys/issues/765#issuecomment-466400999
      //
      halt = 0;
      pc_load = 0;
      reg_re = 0;
      reg_we = 0;
      reg_rs_sel = 0;
      alu_sel1 = 0;
      alu_sel2 = 0;
      alu_op = 0;
      reg_wd_sel = 0;
      mem_addr_sel = 0;
      mem_read_op = LNONE;
      mem_write_op = SNONE;
      inst_load = 0;
      alu_reg_load = 0;
      next_pc_sel = 0;

      if (state == STATE0) begin
         // Read next instruction into output register of ram.
         mem_addr_sel = 0; // pc
         mem_read_op = LW;
         // alu_reg <= pc + 4
         alu_sel1 = 1; // pc
         alu_sel2 = 2; // 4
         alu_op = 0; // +
         alu_reg_load = 1;
      end
      else if (state == STATE1) begin
         // Transfer instruction from output register of ram to the
         // instruction register
         inst_load = 1;
      end
      else if (state == STATE2 & opcode == OP_IMM) begin
         // Load r1
         reg_re = 1;
         reg_rs_sel = 0; // rs1
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
      end
      else if (state == STATE2 & opcode == OP) begin
         // Load r2
         reg_re = 1;
         reg_rs_sel = 1; // rs2
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
      end
      else if (state == STATE2 & opcode == LUI) begin
         // Load r1 with x0
         reg_re = 1;
         reg_rs_sel = 0; // rs1
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
      end
      else if (state == STATE2 & opcode == AUIPC) begin
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
         // alu_reg <= pc+imm
         // It's important we do this now, as we also increment the PC
         // during this cycle.
         alu_sel1 = 1;
         alu_sel2 = 1;
         alu_op = 0;
         alu_reg_load = 1;
      end
      else if (state == STATE2 & opcode == BRANCH) begin
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
         // Load r2
         reg_re = 1;
         reg_rs_sel = 1; // rs2
         // Compute branch target.
         // alu_reg <= pc+imm
         // It's important we do this now, as we also increment the PC
         // during this cycle.
         alu_sel1 = 1; // pc
         alu_sel2 = 1; // imm
         alu_op = 0; // +
         alu_reg_load = 1;
      end
      else if (state == STATE2 & opcode == JAL) begin
         // regfile[rd] <= alu_reg (where alu_reg = pc+4)
         reg_we = 1;
         reg_wd_sel = 0;
         // pc <= pc + imm
         alu_sel1 = 1; // pc
         alu_sel2 = 1; // imm
         alu_op = 0; // +
         pc_load = 1;
         next_pc_sel = 0; // alu_out
      end
      else if (state == STATE2 & opcode == JALR) begin
         // regfile[rd] <= alu_reg (where alu_reg = pc+4)
         reg_we = 1;
         reg_wd_sel = 0;
         // Load r1
         reg_re = 1;
         reg_rs_sel = 0; // rs1
      end
      else if (state == STATE2 & opcode == LOAD) begin
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
         // Load r1
         reg_re = 1;
         reg_rs_sel = 0; // rs1
      end
      else if (state == STATE2 & opcode == STORE) begin
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
         // Load r2
         reg_re = 1;
         reg_rs_sel = 1; // rs2
      end
      else if (state == STATE2 & opcode == MISC_MEM) begin
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
      end
      else if (state == STATE2 & opcode == SYSTEM) begin
         // Assuming `ebreak`
         halt = 1;
      end
      else if (state == FETCH_REG) begin
         // Load r1
         reg_re = 1;
         reg_rs_sel = 0; // rs1
      end
      else if (state == ALU_OP_IMM) begin
         // alu_reg <= rs1 `op` imm
         alu_sel1 = 0; // r1
         alu_sel2 = 1; // imm
         alu_op = {1'b0, funct3 == 3'b101 ? bit30 : 1'b0, funct3};
         alu_reg_load = 1;
      end
      else if (state == ALU_OP) begin
         // alu_reg <= r1 `op` r2
         alu_sel1 = 0; // r1
         alu_sel2 = 0; // r2
         alu_op = {1'b0, bit30, funct3};
         alu_reg_load = 1;
      end
      else if (state == ALU_R1_ADD_IMM) begin
         // alu_reg <= r1 + imm
         alu_sel1 = 0; // r1
         alu_sel2 = 1; // imm
         alu_op = 0; // +
         alu_reg_load = 1;
      end
      else if (state == ALU_TO_RF) begin
         // regfile[rd] <= alu_reg
         reg_we = 1;
         reg_wd_sel = 0; // alu_reg
      end
      else if (state == COND_BRANCH) begin
         // Conditionally update PC
         pc_load = cmp_out;
         next_pc_sel = 1; // alu_reg
         alu_sel1 = 0; // rs1
         alu_sel2 = 0; // rs2
         alu_op = {1'b1, 1'b0,  funct3};
      end
      else if (state == JALR_ALU) begin
         // pc <= r1 + imm
         pc_load = 1;
         next_pc_sel = 0;
         alu_sel1 = 0; // r1
         alu_sel2 = 1; // imm
         alu_op = 0; // +
      end
      else if (state == MEM_READ) begin
         mem_read_op = funct3;
         mem_addr_sel = 1; // alu_reg
      end
      else if (state == MEM_WRITE) begin
         mem_write_op = funct3[1:0];
         mem_addr_sel = 1;
      end
      else if (state == MEM_TO_RF) begin
         reg_we = 1;
         reg_wd_sel = 1; // mem
      end
   end // always @ (*)

endmodule // control
