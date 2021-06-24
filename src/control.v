`default_nettype none

module control(input clk,
               input reset,
               input [6:0] opcode,
               input [2:0] funct3,
               input bit20,
               input bit30,
               input cmp,
               input mem_ready,
               input mie,
               input mtip,
               output reg halt,
               output reg pc_load,
               output reg reg_re,
               output reg reg_we,
               output reg reg_rs_sel, // TODO: It would be better to call this `reg_ra_sel`?
               output reg alu_sel1,
               output reg [1:0] alu_sel2,
               output reg [4:0] alu_op,
               output reg [1:0] reg_wd_sel,
               output reg mem_addr_sel,
               output reg [2:0] mem_read_op,
               output reg [1:0] mem_write_op,
               output reg inst_load,
               output reg alu_reg_load,
               output reg [1:0] next_pc_sel,
               output reg mem_init,
               output reg csr_we,
               output reg [11:0] csr_addr,
               output reg csr_addr_sel,
               output reg mie_set,
               output reg mie_reset,
               output reg cmp_reg_load);

   `include "defs.inc"

   localparam STATE0         = 5'd0;
   localparam STATE1         = 5'd1;
   localparam STATE2         = 5'd2;
   localparam FETCH_REG      = 5'd3;
   localparam ALU_OP_IMM     = 5'd4;
   localparam ALU_OP         = 5'd5;
   localparam ALU_R1_ADD_IMM = 5'd6;
   localparam ALU_TO_RF      = 5'd7;
   localparam COND_BRANCH4   = 5'd8;
   localparam COND_BRANCH5   = 5'd16;
   localparam JALR_ALU       = 5'd9;
   localparam MEM_WRITE      = 5'd10;
   localparam MEM_READ       = 5'd11;
   localparam MEM_TO_RF      = 5'd12;
   localparam INT            = 5'd13;
   localparam CSRRW3         = 5'd14;
   localparam CSRRW4         = 5'd15;

   reg [4:0] state = STATE0, next_state;

   always @(posedge clk) begin
      if (reset)
        state <= STATE0;
      else
        state <= next_state;
   end

   localparam ANY1 = 1'b?;
   localparam ANY3 = 3'b?;
   localparam ANY7 = 7'b?;

   wire take_interrupt;
   assign take_interrupt = mtip & mie;

   // Fields decoded from the instruction (opcode, funct3, imm, etc.)
   // are available from STATE2 and later.
   always @(*) begin
      casez ({state, opcode, mem_ready, funct3, bit20, take_interrupt})
        {STATE0,         ANY7,     ANY1, ANY3, ANY1, 1'b1}: next_state = INT;
        {STATE0,         ANY7,     ANY1, ANY3, ANY1, 1'b0}: next_state = STATE1;
        {STATE1,         ANY7,     1'b0, ANY3, ANY1, ANY1}: next_state = STATE1;
        {STATE1,         ANY7,     1'b1, ANY3, ANY1, ANY1}: next_state = STATE2;
        {STATE2,         OP_IMM,   ANY1, ANY3, ANY1, ANY1}: next_state = ALU_OP_IMM;
        {STATE2,         OP,       ANY1, ANY3, ANY1, ANY1}: next_state = FETCH_REG;
        {STATE2,         LUI,      ANY1, ANY3, ANY1, ANY1}: next_state = ALU_R1_ADD_IMM;
        {STATE2,         AUIPC,    ANY1, ANY3, ANY1, ANY1}: next_state = ALU_TO_RF;
        {STATE2,         BRANCH,   ANY1, ANY3, ANY1, ANY1}: next_state = FETCH_REG;
        {STATE2,         JAL,      ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {STATE2,         JALR,     ANY1, ANY3, ANY1, ANY1}: next_state = JALR_ALU;
        {STATE2,         LOAD,     ANY1, ANY3, ANY1, ANY1}: next_state = ALU_R1_ADD_IMM;
        {STATE2,         STORE,    ANY1, ANY3, ANY1, ANY1}: next_state = FETCH_REG;
        {STATE2,         MISC_MEM, ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {STATE2,         SYSTEM,   ANY1, 3'd0, 1'b1, ANY1}: next_state = state; // ebreak
        {STATE2,         SYSTEM,   ANY1, 3'd0, 1'b0, ANY1}: next_state = STATE0; // mret
        {STATE2,         SYSTEM,   ANY1, 3'd1, ANY1, ANY1}: next_state = CSRRW3; // csrrw
        {FETCH_REG,      BRANCH,   ANY1, ANY3, ANY1, ANY1}: next_state = COND_BRANCH4;
        {FETCH_REG,      OP,       ANY1, ANY3, ANY1, ANY1}: next_state = ALU_OP;
        {FETCH_REG,      STORE,    ANY1, ANY3, ANY1, ANY1}: next_state = ALU_R1_ADD_IMM;
        {ALU_OP_IMM,     ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = ALU_TO_RF;
        {ALU_OP,         ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = ALU_TO_RF;
        {ALU_R1_ADD_IMM, LUI,      ANY1, ANY3, ANY1, ANY1}: next_state = ALU_TO_RF;
        {ALU_R1_ADD_IMM, LOAD,     ANY1, ANY3, ANY1, ANY1}: next_state = MEM_READ;
        {ALU_R1_ADD_IMM, STORE,    ANY1, ANY3, ANY1, ANY1}: next_state = MEM_WRITE;
        {ALU_TO_RF,      ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {COND_BRANCH4,   ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = COND_BRANCH5;
        {COND_BRANCH5,   ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {JALR_ALU,       ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {MEM_READ,       ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = MEM_TO_RF;
        {MEM_WRITE,      ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {MEM_TO_RF,      ANY7,     1'b0, ANY3, ANY1, ANY1}: next_state = MEM_TO_RF;
        {MEM_TO_RF,      ANY7,     1'b1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {INT,            ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        {CSRRW3,         ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = CSRRW4;
        {CSRRW4,         ANY7,     ANY1, ANY3, ANY1, ANY1}: next_state = STATE0;
        default:                                      next_state = state;
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
      // Perhaps also follow:
      // https://github.com/YosysHQ/yosys/issues/2813
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
      mem_init = 0;
      mie_set = 0;
      mie_reset = 0;
      csr_we = 0;
      csr_addr = 0;
      csr_addr_sel = 0;
      cmp_reg_load = 0;

      if (state == STATE0 & ~take_interrupt) begin
         // Read next instruction into output register of ram.
         mem_addr_sel = 0; // pc
         mem_read_op = LW;
         mem_init = 1;
         // alu_reg <= pc + 4
         alu_sel1 = 1; // pc
         alu_sel2 = 2; // 4
         alu_op = 0; // +
         alu_reg_load = 1;
      end
      else if (state == STATE0 & take_interrupt) begin
         // alu_reg <= pc + 0
         alu_sel1 = 1; // pc
         alu_sel2 = 3; // 0
         alu_op = 0; // +
         alu_reg_load = 1;
         // pc <= mvec
         csr_addr = MTVEC;
         csr_addr_sel = 1;
         next_pc_sel = 2; // csr_out
         pc_load = 1;
         // disable interrupts
         // mie <= 0
         mie_reset = 1;
      end
      else if (state == STATE1) begin
         // Continue to drive address bus / read_op while
         // (potentially) waiting for the memory read to happen.
         mem_addr_sel = 0; // pc
         mem_read_op = LW;
         // Transfer instruction from output register of ram to the
         // instruction register
         inst_load = mem_ready;
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
      else if (state == STATE2 & opcode == SYSTEM & funct3 == 3'd0 & bit20) begin
         // ebreak
         halt = 1;
      end
      else if (state == STATE2 & opcode == SYSTEM & funct3 == 3'd0 & ~bit20) begin
         // mret
         // pc <= mecp
         next_pc_sel = 2; // csr
         pc_load = 1;
         csr_addr = MEPC; // mepc
         csr_addr_sel = 1;
         // mie <= 1
         mie_set = 1;
      end
      else if (state == STATE2 & opcode == SYSTEM & funct3 == 3'd1) begin
         // csrrw
         // Store incremented PC
         next_pc_sel = 1;
         pc_load = 1;
         // r1 <= rs1
         reg_re = 1;
         reg_rs_sel = 0;
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
      else if (state == COND_BRANCH4) begin
         // Perform comparison, storing result in cmp_reg
         alu_sel1 = 0; // rs1
         alu_sel2 = 0; // rs2
         alu_op = {1'b1, 1'b0,  funct3};
         cmp_reg_load = 1;
      end
      else if (state == COND_BRANCH5) begin
         // Conditionally update PC
         pc_load = cmp;
         next_pc_sel = 1; // alu_reg
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
         mem_init = 1;
      end
      else if (state == MEM_WRITE) begin
         mem_write_op = funct3[1:0];
         mem_addr_sel = 1;
      end
      else if (state == MEM_TO_RF) begin
         reg_we = mem_ready;
         reg_wd_sel = 1; // mem
         // Continue to drive address bus / read_op while
         // (potentially) waiting for the memory read to happen.
         mem_addr_sel = 1; // alu_reg
         mem_read_op = funct3;
      end
      else if (state == INT) begin
         // mepc <= alu_reg
         csr_addr = MEPC;
         csr_addr_sel = 1;
         csr_we = 1;
      end
      else if (state == CSRRW3) begin
         // alu_reg <= r1 + 0
         alu_sel1 = 0; // r1
         alu_sel2 = 3; // 0
         alu_op = 0; // +
         alu_reg_load = 1;
         // rd <= csr
         csr_addr_sel = 0;
         reg_we = 1;
         reg_wd_sel = 2; // csr_out
      end
      else if (state == CSRRW4) begin
         // csr <= alu_reg
         csr_we = 1;
         csr_addr_sel = 0;
      end
   end // always @ (*)

endmodule // control
