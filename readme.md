# frost

## Introduction

Frost is a simple RISC-V CPU implemented in Verilog. It is written
assuming that it will be synthesised for an FPGA using the open source
tools Yosys, nextpnr, etc.

I'm working on this as way of practising Verilog and learning
something about RISC-V, so you almost certainly don't want it as a
dependency in your project -- there
are [more suitable cores](https://riscv.org/exchange/cores-socs/)
available elsewhere.

Feedback of any kind would be very welcome! You can find my email on
my [homepage](https://paulhorsfall.co.uk/).

## Status

* The base RV32I module is implemented. The
  corresponding [riscv-tests](https://github.com/riscv/riscv-tests/)
  pass.
* Instructions take between 3 and 6 cycles to execute. There is no
  pipelining.
* Unaligned memory reads are not supported. They don't trap either, so
  there's no way to handle them in software.
* The memory interface is very basic. It's suitable for cases where
  everything happens in a single cycle (e.g. an FPGA's on-chip RAM)
  but not much else.

## Project Structure

### [`src`](./src)

Contains all of the Verilog for the RISC-V CPU. `cpu.v` holds the
top-level module. The ISA tests can be run from this directory with
`./run_all_tests.sh`. [Icarus Verilog](http://iverilog.icarus.com/) is
required to run the tests.

### [`system`](./system)

An example of a simple system built around the CPU. It consists of the
CPU plus RAM, UART and a timer. The system can be simulated by running
`./sim.sh <firmware>` from this
directory. [Icarus Verilog](http://iverilog.icarus.com/) is required
to run the simulation.

### [`system/firmware`](./system/firmware)

Contains firmware for the system. Building the firmware requires
the
[GNU RISC-V compiler toolchain](https://github.com/riscv/riscv-gnu-toolchain).

### [`system/tinyfpga`](./system/tinyfpga)

Holds a top-level module and Makefile that support synthesising the
system for the [TinyFPGA BX](https://github.com/tinyfpga/TinyFPGA-BX)
board. This
requires
[Yosys](https://github.com/YosysHQ/yosys),
[nextpnr](https://github.com/YosysHQ/nextpnr) and
the [IceStorm](https://github.com/YosysHQ/icestorm) tools for
synthesis, and [tinyprog](https://pypi.org/project/tinyprog/) for
programming the board. Use `FW=<firmware> make` to run synthesis with
a particular firmware.

### [`tests`](./tests)

The [riscv-tests](https://github.com/riscv/riscv-tests/) assembled
such that they can be run on this implementation.
