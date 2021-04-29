.DELETE_ON_ERROR:

.PHONY: all lint prog clean

# Don't attempt to include test benches in main build.
srcs = $(filter-out %_tb.v, $(wildcard *.v ../*.v ../../src/*.v))

all: fpga.bin

%.json: $(srcs)
	yosys -DFW=\"$(FW)\" -p 'synth_ice40 -top $(basename $@) -json $@' $^

%.asc: %.json pins.pcf
	nextpnr-ice40 --lp8k --package cm81 --freq 16 --json $< --pcf pins.pcf --asc $@

%.bin: %.asc
	icepack $< $@

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
