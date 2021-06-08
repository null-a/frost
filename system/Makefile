.PHONY: all

srcs = $(filter-out %_tb.v, $(wildcard *.v ../src/*.v))

firmwares = $(subst /fw.hex,,$(subst firmware/,,$(wildcard firmware/*/fw.hex)))
$(info Known firmware: $(if $(firmwares),$(firmwares),NONE))

ifeq ($(filter $(FW),$(firmwares)),)
$(error You must specify a firmware using the FW environment variable)
endif

# Runs a simulation of the system in iVerilog. Specify the firmware to
# load using the FW environment variable.
all:
	iverilog -DSIM -DRAM_SIZE_KB=14 -DFW=\"firmware/$(FW)/fw.hex\" -I ../src -o top_tb.vvp -s top_tb $(srcs) top_tb.v
	vvp -n top_tb.vvp
