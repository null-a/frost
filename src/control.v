`default_nettype none

module control(input clk,
               input reset,
               input [6:0] opcode,
               input [2:0] funct3,
               input bit20,
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
               output target_load,
               output [1:0] wd_sel,
               output mem_addr_sel,
               output [2:0] mem_read_op,
               output [1:0] mem_write_op,
               output inst_load,
               output inst_mux_sel);


   localparam OP_IMM   = 7'b0010011;
   localparam LUI      = 7'b0110111;
   localparam AUIPC    = 7'b0010111;
   localparam OP       = 7'b0110011;
   localparam JAL      = 7'b1101111;
   localparam JALR     = 7'b1100111;
   localparam BRANCH   = 7'b1100011;
   localparam LOAD     = 7'b0000011;
   localparam STORE    = 7'b0100011;
   localparam MISC_MEM = 7'b0001111;
   localparam SYSTEM   = 7'b1110011;

   localparam LB    = 3'b000;
   localparam LH    = 3'b001;
   localparam LW    = 3'b010;
   localparam LBU   = 3'b100;
   localparam LHU   = 3'b101;

   localparam LNONE = 3'b011;
   localparam SNONE = 2'b11;

   initial begin
      step = 0;
   end

   wire [1:0] next_step;

   assign next_step = step + 1;

   always @(posedge clk) begin
      if (reset) begin
         step <= 0;
      end
      else begin
         step <= next_step;
      end
   end

   assign halt = opcode == SYSTEM && bit20;
   assign pc_enable = step == 3 && !halt;
   assign pc_load = step == 3 && ((opcode == BRANCH && cmp_out) || opcode == JAL || opcode == JALR);

   assign reg_re1 = step == 1;
   assign reg_re2 = step == 1;
   assign reg_we = step == 3 && (opcode == OP_IMM || opcode == LUI || opcode == OP ||
                                 opcode == AUIPC || opcode == JAL || opcode == JALR ||
                                 opcode == LOAD);

   assign wd_sel = (opcode == JAL || opcode == JALR) ? 2'b01 :
                   opcode == LOAD ? 2'b11 : 2'b00;

   assign mem_addr_sel = step == 2;

   assign mem_read_op = step == 0                  ? LW :
                        step == 2 & opcode == LOAD ? funct3 :
                        /* otherwise */              LNONE;

   assign mem_write_op = step == 2 & opcode == STORE ? funct3[1:0] :
                         /* otherwise */               SNONE;

   assign target_load = step == 1 || (step == 2 && opcode == JALR);

   always @(*) begin
      casez ({step, opcode})
        {2'd1, 7'b?},
        {2'd3, AUIPC}:
          begin
             alu_sel1 = 1; alu_sel2 = 1;
          end
        {2'd3, OP_IMM},
        {2'd3, LUI},
        {2'd2, LOAD},
        {2'd2, STORE},
        {2'd2, JALR}:
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
        {2'd3, OP_IMM, 3'b101}: alu_op = {1'b0, bit30, funct3};
        {2'd3, OP,     3'b?}:   alu_op = {1'b0, bit30, funct3};
        {2'd3, OP_IMM, 3'b?}:   alu_op = {1'b0, 1'b0,  funct3};
        {2'd3, BRANCH, 3'b?}:   alu_op = {1'b1, 1'b0,  funct3};
        default:                 alu_op = {1'b0, 1'b0,  3'b0};
      endcase // casez ({step, opcode, funct3})
   end

   assign inst_load = step == 1;
   assign inst_mux_sel = step == 2 || step == 3;

endmodule // control
