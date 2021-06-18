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

localparam SB    = 2'b00;
localparam SH    = 2'b01;
localparam SW    = 2'b10;
localparam SNONE = 2'b11;

localparam MSTATUS = 12'h300;
localparam MTVEC   = 12'h305;
localparam MIP     = 12'h344;
localparam MEPC    = 12'h341;
