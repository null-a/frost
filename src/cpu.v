`default_nettype none

module cpu(input clk,
           input reset,
           input mem_ready,
           input [31:0] rdata,
           output [31:0] wdata,
           output [29:0] addr,
           output re,
           output [3:0] we);

   wire halt;
   wire pc_load;
   wire [31:0] pc;
   wire [31:0] inst;
   wire [31:0] inst_reg_out;
   wire [31:0] wd;
   wire [6:0] opcode;
   wire [4:0] ra;
   wire [4:0] rd;
   wire [4:0] rs1;
   wire [4:0] rs2;
   wire reg_rs_sel;
   wire [2:0] funct3;
   wire [6:0] funct7;
   wire [31:0] imm;
   wire bit20;
   wire bit30;
   wire reg_re;
   wire reg_we;
   wire [31:0] r1;
   wire [31:0] r2;
   wire [31:0] alu_in1;
   wire [31:0] alu_in2;
   wire [31:0] alu_out;
   wire alu_sel1;
   wire [1:0] alu_sel2;
   wire [4:0] alu_op;
   wire reg_wd_sel;
   wire inst_load;
   wire mem_addr_sel;
   wire [2:0] mem_read_op;
   wire [1:0] mem_write_op;
   wire [31:0] rdata_internal;
   wire [31:0] addr_internal;
   wire alu_reg_load;
   wire [31:0] alu_reg_out;
   wire next_pc_sel;
   wire [31:0] next_pc;

   control control(.clk(clk), .reset(reset), .opcode(opcode), .funct3(funct3), .bit20(bit20), .bit30(bit30),
                   .cmp_out(alu_out[0]),
                   .halt(halt),
                   .pc_load(pc_load),
                   .reg_re(reg_re), .reg_we(reg_we), .reg_rs_sel(reg_rs_sel),
                   .alu_sel1(alu_sel1), .alu_sel2(alu_sel2), .alu_op(alu_op),
                   .alu_reg_load(alu_reg_load),
                   .next_pc_sel(next_pc_sel),
                   .reg_wd_sel(reg_wd_sel),
                   .mem_addr_sel(mem_addr_sel), .mem_read_op(mem_read_op), .mem_write_op(mem_write_op),
                   .inst_load(inst_load), .mem_ready(mem_ready), .mem_init(re));

   mem mem (.clk(clk), .read_op(mem_read_op), .write_op(mem_write_op),
            .we(we),
            .rdata_in(rdata), .rdata_out(rdata_internal),
            .wdata_in(r2), .wdata_out(wdata),
            .addr_in(addr_internal), .addr_out(addr));

   mux next_pc_mux (.a(alu_out), .b(alu_reg_out), .sel(next_pc_sel), .out(next_pc));

   register program_counter(.clk(clk), .din(next_pc), .dout(pc), .en(pc_load));

   mux reg_wd_mux (.a(alu_reg_out), .b(rdata_internal), .sel(reg_wd_sel), .out(wd));

   mux #(.WIDTH(5)) reg_rs_mux (.a(rs1), .b(rs2), .out(ra), .sel(reg_rs_sel));

   reg_file reg_file (.clk(clk), .ra(ra), .wa(rd),
                      .din(wd), .re(reg_re),
                      .we(reg_we), .dout1(r1), .dout2(r2));

   mux #(.WIDTH(32)) mem_addr_mux (.a(pc), .b(alu_reg_out), .out(addr_internal), .sel(mem_addr_sel));

   register inst_reg (.clk(clk), .din(rdata_internal), .dout(inst), .en(inst_load));

   decode decode (.inst(inst), .opcode(opcode),
                  .rd(rd), .rs1(rs1), .rs2(rs2),
                  .funct3(funct3), .funct7(funct7),
                  .imm(imm), .bit20(bit20), .bit30(bit30));

   mux alu_in1_mux (.a(r1), .b(pc), .sel(alu_sel1), .out(alu_in1));
   mux4 alu_in2_mux (.a(r2), .b(imm), .c(32'd4), .d(32'b0), .sel(alu_sel2), .out(alu_in2));

   alu alu (.a(alu_in1), .b(alu_in2), .op(alu_op), .dout(alu_out));

   register alu_reg (.clk(clk), .din(alu_out), .dout(alu_reg_out), .en(alu_reg_load));

endmodule // cpu
