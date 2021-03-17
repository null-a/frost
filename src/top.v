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

   wire rd_uart;
   reg rd_uart_reg = 0;
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


   // Write port available at 0x10000.
   assign wr_uart = &we & addr == 30'h4000;
   // Read port available at 0x10004.
   assign rd_uart = re & addr == 30'h4001;

   always @(posedge clk) begin
      rd_uart_reg <= rd_uart;
   end

   mux rdata_mux (.a(ram_rdata), .b({23'b0, rx_empty, uart_rdata}),
                  .sel(rd_uart_reg), .out(rdata));

   // wire [7:0] rw_data;
   // wire rw;
   // assign rw = ~rx_empty;

   // Do I need to reset on the FPGA, given I can specify initial
   // values for registers? Does dropping it save resources?
   uart #(.FIFO_W(4)) uart (.clk(clk), .reset(reset),
                            .rx(rx), .tx(tx),
                            .w_data(wdata[7:0]), .r_data(uart_rdata),
                            .rx_empty(rx_empty), .tx_full(tx_full),
                            .wr_uart(wr_uart), .rd_uart(rd_uart_reg));

   // A 1 bit output register. Accessed via the low bit of memory
   // address 0x400. (Low two bits of address lines are implicit,
   // hence 0x100 below.)

   always @(posedge clk) begin
      if (addr[8:0] == 9'b100000000 & &we) begin
         out <= wdata[0];
      end
   end

endmodule // top
