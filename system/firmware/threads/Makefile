.PHONY: all clean

all: fw.hex threads.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

handler.o: handler.S
	riscv32-unknown-elf-gcc -c $<

stdlib.o: stdlib.c
	riscv32-unknown-elf-gcc -fno-inline -O2 -c -ffreestanding $<

threads.o: threads.c
	riscv32-unknown-elf-gcc -c -ffreestanding $<

threads.elf: crt0.o handler.o stdlib.o threads.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

%.bin: %.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

fw.hex: threads.bin
	python3 ../../../src/bin2hex.py $< > $@

%.dump: %.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o threads.o threads.elf threads.bin fw.hex threads.dump
