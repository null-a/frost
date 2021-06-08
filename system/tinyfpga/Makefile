.DELETE_ON_ERROR:

.PHONY: all lint prog clean

# Don't attempt to include test benches in main build.
srcs = $(filter-out %_tb.v, $(wildcard *.v ../*.v ../../src/*.v))

firmwares = $(subst /fw.hex,,$(subst ../firmware/,,$(wildcard ../firmware/*/fw.hex)))
$(info Known firmware: $(if $(firmwares),$(firmwares),NONE))
ascs = $(addprefix fpga_, $(addsuffix .asc, $(firmwares)))
bins = $(addprefix fpga_, $(addsuffix .bin, $(firmwares)))

all: $(bins)

dummy.hex:
	icebram -s 0 -g 32 3584 > dummy.hex # 14 KiB

fpga_dummy_fw.json: $(srcs) dummy.hex
	yosys -DFW=\"dummy.hex\" -p 'synth_ice40 -top fpga -json $@' $(srcs)

fpga_dummy_fw.asc: fpga_dummy_fw.json pins.pcf
	nextpnr-ice40 --lp8k --package cm81 --freq 16 --json $< --pcf pins.pcf --asc $@

$(ascs): fpga_%.asc: ../firmware/%/fw.hex fpga_dummy_fw.asc dummy.hex
	icebram dummy.hex $< < fpga_dummy_fw.asc > $@

$(bins): fpga_%.bin: fpga_%.asc
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

ifeq ($(MAKECMDGOALS), prog)
ifeq ($(filter $(FW),$(firmwares)),)
$(error You must specify a firmware using the FW environment variable)
endif
endif

prog: fpga_$(FW).bin
	tinyprog -p $<

clean:
	rm -f *.json *.asc *.bin *_tb.vvp *.vcd obj_dir/* dummy.hex
	rm -df obj_dir
