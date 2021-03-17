`default_nettype none

module mem(input clk,
           input [2:0] read_op,
           input [1:0] write_op,
           output re,
           output reg [3:0] we,
           input [31:0] rdata_in,
           input [31:0] wdata_in,
           output reg [31:0] rdata_out,
           output reg [31:0] wdata_out,
           input [31:0] addr_in,
           output [29:0] addr_out);

   // TODO: Fix duplication with control.v
   localparam LNONE = 3'b011;
   localparam SNONE = 2'b11;

   localparam LB    = 3'b000;
   localparam LH    = 3'b001;
   localparam LW    = 3'b010;
   localparam LBU   = 3'b100;
   localparam LHU   = 3'b101;

   localparam SB = 2'b00;
   localparam SH = 2'b01;
   localparam SW = 2'b10;

   wire [1:0] addr_lo;
   wire [29:0] addr_hi;
   assign {addr_hi, addr_lo} = addr_in;
   assign addr_out = addr_hi;

   wire [7:0] rb0;
   wire [7:0] rb1;
   wire [7:0] rb2;
   wire [7:0] rb3;
   wire [7:0] wb0;
   wire [7:0] wb1;
   wire [7:0] wb2;
   wire [7:0] wb3;
   assign {rb3, rb2, rb1, rb0} = rdata_in;
   assign {wb3, wb2, wb1, wb0} = wdata_in;

   assign re = read_op != LNONE;

   always @(*) begin
      case ({write_op, addr_lo})
        {SB, 2'd0}: begin we = 4'b0001; wdata_out = {24'b0, wb0};       end
        {SB, 2'd1}: begin we = 4'b0010; wdata_out = {16'b0, wb0, 8'b0}; end
        {SB, 2'd2}: begin we = 4'b0100; wdata_out = {8'b0, wb0, 16'b0}; end
        {SB, 2'd3}: begin we = 4'b1000; wdata_out = {wb0, 24'b0};       end
        {SH, 2'd0}: begin we = 4'b0011; wdata_out = {16'b0, wb1, wb0};  end
        {SH, 2'd2}: begin we = 4'b1100; wdata_out = {wb1, wb0, 16'b0};  end
        {SW, 2'd0}: begin we = 4'b1111; wdata_out = wdata_in;           end
        default:    begin we = 4'b0000; wdata_out = 32'bx;              end
      endcase // case ({write_op, addr_in[1:0]})
   end // always @ (*)

   reg [2:0] read_op_reg;
   reg [1:0] addr_lo_reg;

   always @(posedge clk) begin
      read_op_reg <= read_op;
      addr_lo_reg <= addr_lo;
   end

   always @(*) begin
      casez ({read_op_reg, addr_lo_reg})
        {LB, 2'd0}:  rdata_out = {{24{rb0[7]}}, rb0};
        {LB, 2'd1}:  rdata_out = {{24{rb1[7]}}, rb1};
        {LB, 2'd2}:  rdata_out = {{24{rb2[7]}}, rb2};
        {LB, 2'd3}:  rdata_out = {{24{rb3[7]}}, rb3};
        {LH, 2'd0}:  rdata_out = {{16{rb1[7]}}, rb1, rb0};
        {LH, 2'd2}:  rdata_out = {{16{rb3[7]}}, rb3, rb2};
        {LBU, 2'd0}: rdata_out = {24'b0, rb0};
        {LBU, 2'd1}: rdata_out = {24'b0, rb1};
        {LBU, 2'd2}: rdata_out = {24'b0, rb2};
        {LBU, 2'd3}: rdata_out = {24'b0, rb3};
        {LHU, 2'd0}: rdata_out = {16'b0, rb1, rb0};
        {LHU, 2'd2}: rdata_out = {16'b0, rb3, rb2};
        {LW, 2'b?}: rdata_out = rdata_in;
        default:    rdata_out = 32'bx;
      endcase // casez ({read_op_reg, addr_lo_reg})
   end // always @ (*)

endmodule // mem
