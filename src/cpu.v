`default_nettype none

module cpu(input clk,
           input reset,
           input [31:0] ram_rdata,
           output [31:0] ram_wdata,
           output [29:0] ram_addr,
           output ram_re,
           output ram_we);

   wire [1:0] step;
   wire halt;
   wire pc_enable;
   wire pc_load;
   wire [31:0] pc;
   wire [31:0] pc_plus_4;
   wire [31:0] inst;
   wire [31:0] inst_reg_out;
   wire [31:0] wd;
   wire [6:0] opcode;
   wire [4:0] rd;
   wire [4:0] rs1;
   wire [4:0] rs2;
   wire [2:0] funct3;
   wire [6:0] funct7;
   wire [31:0] imm;
   wire bit20;
   wire bit30;
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
   wire [4:0] alu_op;
   wire target_load;
   wire [1:0] wd_sel;
   wire inst_load;
   wire inst_mux_sel;
   wire ram_addr_sel;
   wire [31:0] target;

   assign ram_wdata = r2;

   control control(.clk(clk), .reset(reset), .opcode(opcode), .funct3(funct3), .bit20(bit20), .bit30(bit30),
                   .cmp_out(alu_out[0]),
                   .step(step), .halt(halt),
                   .pc_enable(pc_enable), .pc_load(pc_load),
                   .reg_re1(reg_re1), .reg_re2(reg_re2), .reg_we(reg_we),
                   .alu_sel1(alu_sel1), .alu_sel2(alu_sel2), .alu_op(alu_op),
                   .target_load(target_load), .wd_sel(wd_sel),
                   .ram_addr_sel(ram_addr_sel), .ram_re(ram_re), .ram_we(ram_we),
                   .inst_load(inst_load), .inst_mux_sel(inst_mux_sel));

   program_counter program_counter (.clk(clk), .reset(reset), .en(pc_enable), .load(pc_load),
                                    .target(target), .pc(pc), .pc_plus_4(pc_plus_4));

   mux4 wd_mux (.a(alu_out), .b(pc_plus_4), .c(32'b0), .d(ram_rdata),
                .sel(wd_sel), .out(wd));

   reg_file reg_file (.clk(clk), .ra1(rs1), .ra2(rs2), .wa(rd),
                      .din(wd), .re1(reg_re1), .re2(reg_re2),
                      .we(reg_we), .dout1(r1), .dout2(r2));

   mux #(.WIDTH(30)) ram_addr_mux (.a(pc[31:2]), .b(alu_out[31:2]), .out(ram_addr),
                                 .sel(ram_addr_sel));

   // This combination might be abstracted as a transparent flip-flop?
   register inst_reg (.clk(clk), .din(ram_rdata), .dout(inst_reg_out), .en(inst_load));
   mux inst_mux (.a(ram_rdata), .b(inst_reg_out), .sel(inst_mux_sel), .out(inst));

   decode decode (.inst(inst), .opcode(opcode),
                  .rd(rd), .rs1(rs1), .rs2(rs2),
                  .funct3(funct3), .funct7(funct7),
                  .imm(imm), .bit20(bit20), .bit30(bit30));

   mux alu_in1_mux (.a(r1), .b(pc), .sel(alu_sel1), .out(alu_in1));
   mux alu_in2_mux (.a(r2), .b(imm), .sel(alu_sel2), .out(alu_in2));

   alu alu (.a(alu_in1), .b(alu_in2), .op(alu_op), .dout(alu_out));

   register target_reg (.clk(clk), .din(alu_out), .dout(target), .en(target_load));

endmodule // cpu
