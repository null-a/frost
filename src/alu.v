`default_nettype none

module alu(input [31:0] a,
           input [31:0] b,
           input [2:0] op,
           output [31:0] dout);

   assign dout = op == 3'b1 ? {31'b0, a != b} : a + b;

endmodule // alu
