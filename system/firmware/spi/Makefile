.PHONY: all clean

all: fw.hex spi.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

stdlib.o: stdlib.c
	riscv32-unknown-elf-gcc -fno-inline -O2 -c -ffreestanding $<

spi.o: spi.c
	riscv32-unknown-elf-gcc -O2 -c -ffreestanding $<

spi.elf: crt0.o stdlib.o spi.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

spi.bin: spi.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

fw.hex: spi.bin
	python3 ../../../src/bin2hex.py spi.bin > fw.hex

spi.dump: spi.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o spi.o spi.elf spi.bin fw.hex spi.dump
