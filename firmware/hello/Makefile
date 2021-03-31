.PHONY: all clean

all: hello.hex hello.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

hello.o: hello.c
	riscv32-unknown-elf-gcc -c -ffreestanding $<

hello.elf: crt0.o hello.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

# TODO: Look into dumping verilog directly.
hello.bin: hello.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

hello.hex: hello.bin
	python3 ../../src/bin2hex.py hello.bin > hello.hex

hello.dump: hello.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o hello.o hello.elf hello.bin hello.hex hello.dump
