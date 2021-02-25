`default_nettype none

module alu(input [31:0] a,
           input [31:0] b,
           input [4:0] op,
           output reg [31:0] dout);

   always @(*) begin
      casez (op)
        {1'b1, 1'b?, 3'b001}: dout = {31'b0, a != b};
        default:              dout = a + b;
      endcase // casez (op)
   end

endmodule // alu
