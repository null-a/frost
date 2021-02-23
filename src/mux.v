`default_nettype none

module mux(input [31:0] a,
           input [31:0] b,
           input sel,
           output [31:0] out);

   assign out = sel ? b : a;

endmodule // mux
