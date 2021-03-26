.PHONY: all clean

all: echo.hex echo.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

echo.o: echo.c
	riscv32-unknown-elf-gcc -c -ffreestanding $<

echo.elf: crt0.o echo.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

# TODO: Look into dumping verilog directly.
echo.bin: echo.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

echo.hex: echo.bin
	python3 ../../src/bin2hex.py echo.bin > echo.hex

echo.dump: echo.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o echo.o echo.elf echo.bin
