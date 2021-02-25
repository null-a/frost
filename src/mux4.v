`default_nettype none

module mux4(input [31:0] a,
            input [31:0] b,
            input [31:0] c,
            input [31:0] d,
            input [1:0] sel,
            output [31:0] out);

   assign out = sel == 2'b00 ? a :
                sel == 2'b01 ? b :
                sel == 2'b10 ? c : d;

endmodule // mux4
