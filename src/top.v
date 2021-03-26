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

   wire rd_uart, rd_uart_reg;
   reg rd_uart_prev = 0;
   reg rd_uart_reg_prev = 0;
   wire wr_uart;
   wire rx_empty;
   wire tx_full;

   cpu cpu (.clk(clk), .reset(reset),
            .addr(addr), .wdata(wdata), .rdata(rdata),
            .re(re), .we(we));

   assign ram_en = addr[29:14] == 16'b0;

   ram ram (.clk(clk), .addr(addr[10:0]),
            .din(wdata), .dout(ram_rdata),
            .re(ram_en & re), .we(ram_en ? we : 4'b0));


   // Write port available at 0x10000 (tx).
   assign wr_uart = &we & addr == 30'h4000;

   // Read port available at 0x10000 (tx) and 0x10004 (rx).
   assign rd_uart = re & ((addr == 30'h4000) | (addr == 30'h4001));
   assign rd_uart_reg = addr[0]; // Which UART register as we reading from?

   // We delay by one cycle to ensure the data is presented when the
   // CPU expects. (This mimics the register on the output of RAM.)
   always @(posedge clk) begin
      rd_uart_prev <= rd_uart;
      rd_uart_reg_prev <= rd_uart_reg;
   end

   assign rdata = ~rd_uart_prev            ? ram_rdata :
                  rd_uart_reg_prev == 1'b0 ? {31'b0, tx_full} :
                  /* otherwise */            {23'b0, rx_empty, uart_rdata};

   // Do I need to reset on the FPGA, given I can specify initial
   // values for registers? Does dropping it save resources?
   uart #(.FIFO_W(4)) uart (.clk(clk), .reset(reset),
                            .rx(rx), .tx(tx),
                            .w_data(wdata[7:0]), .r_data(uart_rdata),
                            .rx_empty(rx_empty), .tx_full(tx_full),
                            .wr_uart(wr_uart), .rd_uart(rd_uart_prev));

   // A 1 bit output register. Accessed via the low bit of memory
   // address 0x400. (Low two bits of address lines are implicit,
   // hence 0x100 below.)

   always @(posedge clk) begin
      if (addr[8:0] == 9'b100000000 & &we) begin
         out <= wdata[0];
      end
   end

endmodule // top
