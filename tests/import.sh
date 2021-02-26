ls ../../riscv_simulator/tests/isa/*.bin | xargs -I{} basename {} .bin | xargs -I{} sh -c 'python3 ../src/bin2hex.py ../../riscv_simulator/tests/isa/$1.bin > $1.hex' -- {}
