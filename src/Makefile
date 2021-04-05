.DELETE_ON_ERROR:

.PHONY: all lint prog clean

# Don't attempt to include test benches in main build.
srcs = $(filter-out %_tb.v, $(wildcard *.v))

all: fpga.bin

%.json: $(srcs)
	yosys -p 'synth_ice40 -top $(basename $@) -json $@' $^

%.asc: %.json pins.pcf
	nextpnr-ice40 --lp8k --package cm81 --freq 16 --json $< --pcf pins.pcf --asc $@

%.bin: %.asc
	icepack $< $@

# Don't include fpga.v/pll.v when running iverilog, since it doesn't
# know where to find the PLL primitives.
%_tb.vvp: %_tb.v $(filter-out fpga.v pll.v, $(srcs))
	iverilog -DSIM -DRAM_SIZE_KB=14 -o $@ $^

# I'm assuming that a test bench always makes a VCD file of similar
# name.
%.vcd: %_tb.vvp
	vvp -n $<

lint:
	$(VERILATOR) -lint-only $(srcs)

# h/t:
# https://github.com/verilator/verilator/blob/master/examples/make_hello_c/Makefile

# This assumes that VERILATOR_ROOT is defined, as it is locally for
# me.
VERILATOR = $(VERILATOR_ROOT)/bin/verilator

prog: fpga.bin
	tinyprog -p $<

clean:
	rm -f *.json *.asc *.bin *_tb.vvp *.vcd obj_dir/*
	rm -df obj_dir
