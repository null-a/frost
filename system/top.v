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

   cpu cpu (.clk(clk), .reset(reset),
            .addr(addr), .wdata(wdata), .rdata(rdata),
            .re(re), .we(we), .mem_ready(1'b1));

   localparam NUM_WORDS = 14 * 1024 / 4;

   assign ram_en = ~addr[14];

   ram #(.NUM_WORDS(NUM_WORDS)) ram (.clk(clk), .addr(addr),
                                     .din(wdata), .dout(ram_rdata),
                                     .re(ram_en & re), .we(ram_en ? we : 4'b0));


   // We need to multiplex the appropriate data source onto `rdata`
   // the cycle *after* the `re` tick. (This is how the RAM works
   // because of its output register, and the CPU is designed around
   // it.) To facilitate this, we remember that state of `ram_en` for
   // one cycle.

   reg ram_en_prev = 0;
   always @(posedge clk) begin
      ram_en_prev <= ram_en;
   end

   // We also need to remember sufficient information about the read
   // address.

   // If we aren't doing a read from RAM, we multiplex the appropriate
   // register onto the `rdata` bus, regardless of whether we're doing
   // a read. We remember the low bits of the address to distinguish
   // between registers. (This approach will result in the registers
   // been mirrored across the whole address space above RAM.)

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


   reg in0_reg0;
   reg in0_reg1;

   always @(posedge clk) begin
      in0_reg0 <= in0;
      in0_reg1 <= in0_reg0;
   end

   assign rdata = ram_en_prev        ? ram_rdata :
                  addr_prev == 2'b00 ? {31'b0, tx_full} :
                  addr_prev == 2'b01 ? {23'b0, rx_empty, uart_rdata} :
                  addr_prev == 2'b10 ? ms_count :
                  /* otherwise */      {31'b0, in0_reg1};

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
