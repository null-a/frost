.PHONY: all clean

all: blinky.hex blinky.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

blinky.o: blinky.c
	riscv32-unknown-elf-gcc -c -ffreestanding $<

blinky.elf: crt0.o blinky.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

blinky.bin: blinky.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

blinky.hex: blinky.bin
	python3 ../../../src/bin2hex.py blinky.bin > blinky.hex

blinky.dump: blinky.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o blinky.o blinky.elf blinky.bin blinky.hex blinky.dump
