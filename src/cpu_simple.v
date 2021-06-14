`default_nettype none

// This module wraps `cpu`, simplifying its memory interface. This
// interface required that connected memory devices are (32 bit) word
// addressable, and that per-byte write enable is supported. Note that
// when using this interface, the CPU will not be able to perform
// unaligned operations.

module cpu_simple(input clk,
                  input reset,
                  input mem_ready,
                  input [31:0] rdata,
                  output [31:0] wdata,
                  output [29:0] addr,
                  output re,
                  output [3:0] we);

   wire [2:0] mem_read_op;
   wire [1:0] mem_write_op;
   wire [31:0] rdata_internal;
   wire [31:0] wdata_internal;
   wire [31:0] addr_internal;

   cpu cpu (.clk(clk), .reset(reset),
            .mem_ready(mem_ready), .mem_init(re),
            .mem_read_op(mem_read_op), .mem_write_op(mem_write_op),
            .rdata(rdata_internal), .wdata(wdata_internal),
            .addr(addr_internal));

   mem mem (.clk(clk),
            .read_op(mem_read_op), .write_op(mem_write_op),
            .we(we),
            .rdata_in(rdata), .rdata_out(rdata_internal),
            .wdata_in(wdata_internal), .wdata_out(wdata),
            .addr_in(addr_internal), .addr_out(addr));

endmodule // cpu_simple_mem
