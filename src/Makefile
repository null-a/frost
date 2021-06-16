.PHONY: cpu_block_diagram

srcs = $(filter-out %_tb.v, $(wildcard *.v ../*.v ../../src/*.v))

cpu_block_diagram:
	yosys -QTqq -p "read_verilog -lib $(srcs); read_verilog cpu.v; opt; show -colors 1 -width -stretch -notitle"
