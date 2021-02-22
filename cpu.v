`default_nettype none

module cpu(input clk);

   wire [1:0] step;
   wire pc_enable;
   wire [31:0] pc;
   wire [31:0] inst;
   wire [6:0] opcode;
   wire [4:0] rd;
   wire [4:0] rs1;
   wire [4:0] rs2;
   wire [2:0] funct3;
   wire [6:0] funct7;
   wire [11:0] imm;

   control control(.clk(clk), .step(step), .pc_enable(pc_enable));

   program_counter program_counter (.clk(clk), .en(pc_enable), .load(1'b0),
                                    .target(0), .pc(pc));

   ram ram (.clk(clk), .addr(pc[31:2]), .din(0),
            .re(1'b1), .we(1'b0), .dout(inst));

   decode decode (.inst(inst), .opcode(opcode),
                  .rd(rd), .rs1(rs1), .rs2(rs2),
                  .funct3(funct3), .funct7(funct7),
                  .imm(imm));

endmodule // cpu
