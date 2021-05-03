ls ~/riscv-tests/isa/rv32ui/*.S | xargs -I '{}' basename '{}' | xargs -I '{}' cp ~/riscv-tests/isa/rv64ui/{} .
sed 's/RVTEST_RV64U/RVTEST_RV32U/' -i *.S
