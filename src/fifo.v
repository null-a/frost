`default_nettype none

module fifo
  #(parameter
    B=8, // number of bits in a word
    W=4  // number of address bits 4
    )
   (input clk, reset, rd, wr,
    input [B-1:0] w_data,
    output empty, full,
    output [B-1:0] r_data
    );

   reg [B-1:0] array_reg [2**W-1:0]; // register array
   reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
   reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
   reg full_reg, empty_reg, full_next, empty_next;

   wire wr_en;

   assign full = full_reg;
   assign empty = empty_reg;

   // register file write operation
   always @(posedge clk)
     if (wr_en)
       array_reg[w_ptr_reg] <= w_data;

   // register file read operation
   assign r_data = array_reg[r_ptr_reg];

   // write enabled only when FIFO is not full
   assign wr_en = wr & ~full_reg;

   // fifo control logic
   // register for read and write pointers
   always @(posedge clk) begin
      if (reset) begin
         w_ptr_reg <= 0;
         r_ptr_reg <= 0;
         full_reg <= 1'b0;
         empty_reg <= 1'b1;
      end
      else begin
         w_ptr_reg <= w_ptr_next;
         r_ptr_reg <= r_ptr_next;
         full_reg <= full_next;
         empty_reg <= empty_next;
      end // else: !if(reset)
   end // always @ (posedge clk)

   always @* begin
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;
      // defaults
      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;
      case ({wr, rd})
        // 2'b00: no op
        2'b01: begin // read
           if (~empty_reg) begin
              r_ptr_next = r_ptr_succ;
              full_next = 1'b0;
              if (r_ptr_succ == w_ptr_reg)
                empty_next = 1'b1;
           end
        end
        2'b10: begin // write
           if (~full_reg) begin
              w_ptr_next = w_ptr_succ;
              empty_next = 1'b0;
              if (w_ptr_succ == r_ptr_reg)
                full_next =  1'b1;
           end
        end
        2'b11: begin // write and read
           w_ptr_next = w_ptr_succ;
           r_ptr_next = r_ptr_succ;
        end
      endcase // case ({wr, rd})
   end // always @ *

endmodule // fifo
