`default_nettype none

module top (input clk,
            input reset,
            input rx,
            output tx,
            output reg out);

   wire re;
   wire [3:0] we;
   wire [29:0] addr;
   wire [31:0] rdata;
   wire [31:0] wdata;

   wire [31:0] ram_rdata;
   wire [7:0] uart_rdata;

   wire ram_en;

   cpu cpu (.clk(clk), .reset(reset),
            .addr(addr), .wdata(wdata), .rdata(rdata),
            .re(re), .we(we));

   localparam RAM_SIZE_KB = `ifdef RAM_SIZE_KB `RAM_SIZE_KB `else 8 `endif;
   localparam NUM_WORDS = RAM_SIZE_KB * 1024 / 4;

   assign ram_en = addr < NUM_WORDS;

   ram #(.NUM_WORDS(NUM_WORDS)) ram (.clk(clk), .addr(addr),
                                     .din(wdata), .dout(ram_rdata),
                                     .re(ram_en & re), .we(ram_en ? we : 4'b0));


   // We need to multiple the appropriate data source onto `rdata` the
   // cycle *after* the `re` tick. (Since there's an output register
   // on RAM.) We need to remember sufficient information about the
   // read address to facilitate this. We need to distinguish between
   // RAM and any of the registers.

   // TODO: Is this really necessary? Maybe it is already the case
   // that the read address continues to be available during the cycle
   // after the `re` tick. And if not, perhaps it's easy to arrange
   // for this to be so?

   reg ram_en_prev = 0;
   always @(posedge clk) begin
      ram_en_prev <= ram_en;
   end

   // Remember the low bits of the address to distinguish between
   // registers. (This approach will result in the registers been
   // mirrored across the whole address space above RAM.)
   reg [1:0] addr_prev = 2'b0;

   always @(posedge clk) begin
      addr_prev <= addr[1:0];
   end


   wire rd_uart;
   wire wr_uart;
   // Write port available at 0x10000 (tx). (Can also be read to check
   // tx_full.)
   assign wr_uart = &we & addr == 30'h4000;
   // Read port available at 0x10004 (rx).
   assign rd_uart = re & addr == 30'h4001;

   // We delay by one cycle to ensure the data is presented when the
   // CPU expects. (This mimics the register on the output of RAM.)
   reg rd_uart_prev = 0;
   always @(posedge clk) begin
      rd_uart_prev <= rd_uart;
   end

   assign rdata = ram_en_prev        ? ram_rdata :
                  addr_prev == 2'b00 ? {31'b0, tx_full} :
                  addr_prev == 2'b01 ? {23'b0, rx_empty, uart_rdata} :
                  /* otherwise */      ms_count;

   wire rx_empty;
   wire tx_full;

   // Do I need to reset on the FPGA, given I can specify initial
   // values for registers? Does dropping it save resources?
   uart #(.FIFO_W(4)) uart (.clk(clk), .reset(reset),
                            .rx(rx), .tx(tx),
                            .w_data(wdata[7:0]), .r_data(uart_rdata),
                            .rx_empty(rx_empty), .tx_full(tx_full),
                            .wr_uart(wr_uart), .rd_uart(rd_uart_prev));

   wire [31:0] ms_count;
   ms_counter ms_counter (.clk(clk), .out(ms_count));

   // A 1 bit output register. Accessed via the low bit of memory
   // address 0x400. (Low two bits of address lines are implicit,
   // hence 0x100 below.)

   always @(posedge clk) begin
      if (addr[8:0] == 9'b100000000 & &we) begin
         out <= wdata[0];
      end
   end

endmodule // top
