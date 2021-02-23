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
   wire [31:0] imm;
   wire reg_re1;
   wire reg_re2;
   wire reg_we;
   wire [31:0] r1;
   wire [31:0] r2;
   wire [31:0] alu_in1;
   wire [31:0] alu_in2;
   wire [31:0] alu_out;
   wire alu_sel1;
   wire alu_sel2;

   control control(.clk(clk), .opcode(opcode), .step(step), .pc_enable(pc_enable),
                   .reg_re1(reg_re1), .reg_re2(reg_re2), .reg_we(reg_we),
                   .alu_sel1(alu_sel1), .alu_sel2(alu_sel2));

   program_counter program_counter (.clk(clk), .en(pc_enable), .load(1'b0),
                                    .target(0), .pc(pc));

   reg_file reg_file (.clk(clk), .ra1(rs1), .ra2(rs2), .wa(rd),
                      .din(alu_out), .re1(reg_re1), .re2(reg_re2),
                      .we(reg_we), .dout1(r1), .dout2(r2));

   ram ram (.clk(clk), .addr(pc[31:2]), .din(0),
            .re(1'b1), .we(1'b0), .dout(inst));

   decode decode (.inst(inst), .opcode(opcode),
                  .rd(rd), .rs1(rs1), .rs2(rs2),
                  .funct3(funct3), .funct7(funct7),
                  .imm(imm));

   mux alu_in1_mux (.a(r1), .b(pc), .sel(alu_sel1), .out(alu_in1));
   mux alu_in2_mux (.a(r2), .b(imm), .sel(alu_sel2), .out(alu_in2));

   alu alu (.a(alu_in1), .b(alu_in2), .op(4'b0), .dout(alu_out));

endmodule // cpu
