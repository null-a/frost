.PHONY: all clean

all: test.hex test.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

%.o: %.c
	riscv32-unknown-elf-gcc -c -ffreestanding $<

test.elf: crt0.o stdlib.o test.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

# TODO: Look into dumping verilog directly.
test.bin: test.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

test.hex: test.bin
	python3 ../../src/bin2hex.py test.bin > test.hex

test.dump: test.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o stdlib.o test.o test.elf test.bin
