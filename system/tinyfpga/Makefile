.DELETE_ON_ERROR:

.PHONY: all lint prog clean

# Don't attempt to include test benches in main build.
srcs = $(filter-out %_tb.v, $(wildcard *.v ../*.v ../../src/*.v))

all: fpga.bin

dummy.hex:
	icebram -s 0 -g 32 3584 > dummy.hex # 14 KiB

fpga_dummy_fw.json: $(srcs) dummy.hex
	yosys -DFW=\"dummy.hex\" -p 'synth_ice40 -top fpga -json $@' $(srcs)

fpga_dummy_fw.asc: fpga_dummy_fw.json pins.pcf
	nextpnr-ice40 --lp8k --package cm81 --freq 16 --json $< --pcf pins.pcf --asc $@

fpga.asc: fpga_dummy_fw.asc dummy.hex $(FW)
ifeq ($(FW),)
	$(error You must specify a firmware to use by setting the FW environment variable)
endif
	icebram dummy.hex $(FW) < fpga_dummy_fw.asc > fpga.asc

%.bin: %.asc
	icepack $< $@

%.vcd: %_tb.vvp
	vvp -n $<

lint:
	$(VERILATOR) -I../../src -lint-only $(srcs)

# h/t:
# https://github.com/verilator/verilator/blob/master/examples/make_hello_c/Makefile

# This assumes that VERILATOR_ROOT is defined, as it is locally for
# me.
VERILATOR = $(VERILATOR_ROOT)/bin/verilator

prog: fpga.bin
	tinyprog -p $<

clean:
	rm -f *.json *.asc *.bin *_tb.vvp *.vcd obj_dir/* dummy.hex
	rm -df obj_dir
