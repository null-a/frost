`default_nettype none

module decode(input [31:0] inst,
              output [6:0] opcode,
              output [4:0] rd,
              output [4:0] rs1,
              output [4:0] rs2,
              output [2:0] funct3,
              output [6:0] funct7,
              output reg [31:0] imm,
              output bit20,
              output bit30);

   `include "defs.inc"

   assign opcode = inst[6:0];
   assign rd = inst[11:7];
   assign funct3 = inst[14:12];
   assign rs1 = opcode == LUI ? 5'b0 : inst[19:15];
   assign rs2 = inst[24:20];
   assign funct7 = inst[31:25];

   assign bit20 = inst[20];
   assign bit30 = inst[30];

   wire signbit;
   assign signbit = inst[31];

   always @(*) begin
      case (opcode)
        STORE:   // S
          imm = {{21{signbit}}, inst[30:25], inst[11:7]};
        // TODO: Droping this case doesn't cause a test failure.
        JAL:     // J
          imm = {{12{signbit}}, inst[19:12], inst[20], inst[30:21], 1'b0};
        LUI,     // U
        AUIPC:
          imm = {inst[31:12], 12'b0};
        BRANCH:  // B
          imm = {{20{signbit}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        default: // I
          imm = {{21{signbit}}, inst[30:20]};

      endcase
   end

endmodule // decode
