`default_nettype none

module clear_lsb(input en,
                 input [31:0] din,
                 output [31:0] dout);

   assign dout = {din[31:1], en ? 1'b0 : din[0]};

endmodule // clear_lsb
