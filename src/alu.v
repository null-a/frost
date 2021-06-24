`default_nettype none

module alu(input [31:0] a,
           input [31:0] b,
           input [4:0] op,
           output reg [31:0] dout);

   always @(*) begin
      casez (op)
        {1'b0, 1'b0, 3'd0}: dout = a + b;
        {1'b0, 1'b1, 3'd0}: dout = a - b;
        {1'b0, 1'b?, 3'd1}: dout = a << b[4:0];
        {1'b0, 1'b?, 3'd4}: dout = a ^ b;

        {1'b0, 1'b0, 3'd5}: dout = a >> b[4:0];
        {1'b0, 1'b1, 3'd5}: dout = $signed(a) >>> b[4:0];

        {1'b0, 1'b?, 3'd6}: dout = a | b;
        {1'b0, 1'b?, 3'd7}: dout = a & b;

        {1'b0, 1'b?, 3'd2}: dout = {31'b0, $signed(a) < $signed(b)};
        {1'b0, 1'b?, 3'd3}: dout = {31'b0, a < b};

        {1'b1, 1'b?, 3'd0}: dout = {31'b0, a == b};
        {1'b1, 1'b?, 3'd1}: dout = {31'b0, a != b};

        {1'b1, 1'b?, 3'd4}: dout = {31'b0, $signed(a) < $signed(b)};
        {1'b1, 1'b?, 3'd6}: dout = {31'b0, a < b};
        {1'b1, 1'b?, 3'd5}: dout = {31'b0, $signed(a) >= $signed(b)};
        {1'b1, 1'b?, 3'd7}: dout = {31'b0, a >= b};

        {1'b1, 1'b?, 3'd2}: dout = a;
        {1'b1, 1'b?, 3'd3}: dout = b;

        default: begin
           $display("error: unknown alu op");
           dout = 32'b0;
        end

      endcase // casez (op)
   end

endmodule // alu
