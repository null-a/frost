`default_nettype none

module alu(input [31:0] a,
           input [31:0] b,
           input [3:0] op,
           output [31:0] dout);

   assign dout = a + b;

endmodule // alu
