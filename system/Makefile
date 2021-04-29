.PHONY: all

srcs = $(filter-out %_tb.v, $(wildcard *.v ../src/*.v))

# Runs a simulation of the system in iVerilog. This expects to find a
# "firmware.hex" in the same directory as this Makefile.
all:
	iverilog -DSIM -DRAM_SIZE_KB=14 -I ../src -o top_tb.vvp -s top_tb $(srcs) top_tb.v
	vvp -n top_tb.vvp
