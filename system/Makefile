.PHONY: all

srcs = $(filter-out %_tb.v, $(wildcard *.v ../src/*.v))

# Runs a simulation of the system in iVerilog. Specify the firmware to
# load using the FW environment variable.
all:
	iverilog -DSIM -DRAM_SIZE_KB=14 -DFW=\"$(FW)\" -I ../src -o top_tb.vvp -s top_tb $(srcs) top_tb.v
	vvp -n top_tb.vvp
