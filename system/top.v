`default_nettype none

module top (input clk,
            input reset,
            output reg led,
            input rx,
            output tx,
            // GPIO
            input in0,
            inout out0, // `inout` to allow high impedance
            inout out1,
            inout out2,
            inout out3);

   wire re;
   wire [3:0] we;
   wire [29:0] addr;
   wire [31:0] rdata;
   wire [31:0] wdata;

   wire [31:0] ram_rdata;
   wire [7:0] uart_rdata;

   wire ram_en;

   cpu_simple cpu (.clk(clk), .reset(reset), .irq(irq),
                   .addr(addr), .wdata(wdata), .rdata(rdata),
                   .re(re), .we(we), .mem_ready(1'b1));

   // The first 64 KBytes of the address space are reserved for RAM.
   // Not all of this is used. (Note that `addr` doesn't include the
   // two least significant bits since `cpu_simple` assumes only word
   // addressable memory.)
   assign ram_en = ~addr[14];

   localparam NUM_WORDS = 14 * 1024 / 4;

   ram #(.NUM_WORDS(NUM_WORDS)) ram (.clk(clk), .addr(addr),
                                     .din(wdata), .dout(ram_rdata),
                                     .re(ram_en & re), .we(ram_en ? we : 4'b0));

   wire irq;
   wire [31:0] mtimer_out;
   wire mtimer_we;
   assign mtimer_we = ~ram_en & (addr[3:0] == 4'b1010 || addr[3:0] == 4'b1011);
   mtimer mtimer (.clk(clk), .din(wdata), .we(mtimer_we), .addr(addr[1:0]), .irq(irq), .dout(mtimer_out));

   /*

    Register Memory Map
    ===================
    _____________________________________
            |              |
    address | read         | write
    ________|______________|_____________
            |              |
    0x10000 | uart tx_full | uart tx
    0x10004 | uart rx      |
    0x10008 |              | on-board led
    0x1000C | gpio in0     | gpio out0
    0x10010 |              | gpio out1
    0x10014 |              | gpio out2
    0x10018 |              | gpio out3
    0x1001C |              |
    0x10020 | mtime (l)    |
    0x10024 | mtime (h)    |
    0x10028 | mtimecmp (l) | mtimecmp (l)
    0x1002C | mtimecmp (h) | mtimecmp (h)
    ________|______________|_____________

    */

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


   reg in0_reg0;
   reg in0_reg1;

   always @(posedge clk) begin
      in0_reg0 <= in0;
      in0_reg1 <= in0_reg0;
   end

   assign rdata = ram_en               ? ram_rdata :
                  addr[3:0] == 4'b0000 ? {31'b0, tx_full} :
                  addr[3:0] == 4'b0001 ? {23'b0, rx_empty, uart_rdata} :
                  addr[3:0] == 4'b0011 ? {31'b0, in0_reg1} :
                  /* otherwise */        mtimer_out;

   wire rx_empty;
   wire tx_full;

   // Do I need to reset on the FPGA, given I can specify initial
   // values for registers? Does dropping it save resources?
   uart #(.FIFO_W(4)) uart (.clk(clk), .reset(reset),
                            .rx(rx), .tx(tx),
                            .w_data(wdata[7:0]), .r_data(uart_rdata),
                            .rx_empty(rx_empty), .tx_full(tx_full),
                            .wr_uart(wr_uart), .rd_uart(rd_uart_prev));

   // GPIO. Mapped at 0x10008, 0x1000C, 0x10010, 0x10014, 0x10018.
   // See blinky firmware for example of use.

   // Outputs are tri-state. Writing 0 or 1 sets the output low or
   // high respectively. Writing a 2 puts the output in a
   // high-impedance state. Outputs default to the high impedance
   // state.

   reg [1:0] reg_out0 = 2'b10;
   reg [1:0] reg_out1 = 2'b10;
   reg [1:0] reg_out2 = 2'b10;
   reg [1:0] reg_out3 = 2'b10;

   assign out0 = reg_out0[1] ? 1'bz : reg_out0[0];
   assign out1 = reg_out1[1] ? 1'bz : reg_out1[0];
   assign out2 = reg_out2[1] ? 1'bz : reg_out2[0];
   assign out3 = reg_out3[1] ? 1'bz : reg_out3[0];

   always @(posedge clk) begin
      if (addr == 30'h4002 & &we) begin
         led <= wdata[0];
      end
      if (addr == 30'h4003 & &we) begin
         reg_out0 <= wdata[1:0];
      end
      if (addr == 30'h4004 & &we) begin
         reg_out1 <= wdata[1:0];
      end
      if (addr == 30'h4005 & &we) begin
         reg_out2 <= wdata[1:0];
      end
      if (addr == 30'h4006 & &we) begin
         reg_out3 <= wdata[1:0];
      end
   end

endmodule // top
