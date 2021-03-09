`default_nettype none

module uart
  #(parameter
    DBIT = 8,
    FIFO_W = 2
    )
   (input clk, reset, rd_uart, wr_uart, rx,
    input [7:0] w_data,
    output tx_full, rx_empty, tx,
    output [7:0] r_data,
    output [7:0] debug
    );

   wire tick, rx_done_tick, tx_done_tick;
   wire tx_empty, tx_fifo_not_empty;
   wire [7:0] tx_fifo_out, rx_data_out;

   assign tx_fifo_not_empty = ~tx_empty;

   // Given the 16 MHz clock, this gives a baud rate of 19200.
   mod_m_counter #(.M(52), .N(6)) baud_gen_unit
     (.clk(clk), .reset(reset), .max_tick(tick));

   uart_rx uart_rx_unit
     (.clk(clk), .reset(reset), .rx(rx), .s_tick(tick),
      .rx_done_tick(rx_done_tick), .dout(rx_data_out));

   fifo #(.B(DBIT), .W(FIFO_W)) fifo_rx_unit
     (.clk(clk), .reset(reset), .rd(rd_uart),
      .wr(rx_done_tick), .w_data(rx_data_out),
      .empty(rx_empty), .r_data(r_data));

   fifo #(.B(DBIT), .W(FIFO_W)) fifo_tx_unit
     (.clk(clk), .reset(reset), .rd(tx_done_tick),
      .wr(wr_uart), .w_data(w_data), .empty(tx_empty),
      .full(tx_full), .r_data(tx_fifo_out));

   uart_tx uart_tx_unit
     (.clk(clk), .reset(reset), .tx_start(tx_fifo_not_empty),
      .s_tick(tick), .din(tx_fifo_out),
      .tx_done_tick(tx_done_tick), .tx(tx));

endmodule // uart
