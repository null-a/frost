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
