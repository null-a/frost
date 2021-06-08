.PHONY: all clean

all: fw.hex dhry.dump

crt0.o: crt0.S
	riscv32-unknown-elf-gcc -c $<

stdlib.o: stdlib.c
	riscv32-unknown-elf-gcc -fno-inline -O2 -c -ffreestanding $<

dhry_1.o: dhry_1.c
	riscv32-unknown-elf-gcc -fno-inline -O2 -DTIME -c -ffreestanding $<

dhry_2.o: dhry_2.c
	riscv32-unknown-elf-gcc -fno-inline -O2 -DTIME -c -ffreestanding $<

dhry.elf: crt0.o stdlib.o dhry_1.o dhry_2.o
	riscv32-unknown-elf-ld $^ -T script.ld -lgcc -L $$(dirname `riscv32-unknown-elf-gcc -print-libgcc-file-name`) -o $@

# TODO: Look into dumping verilog directly.
%.bin: %.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

fw.hex: dhry.bin
	python3 ../../../src/bin2hex.py $< > $@

%.dump: %.elf
	riscv32-unknown-elf-objdump -D -Mnumeric $< > $@

clean:
	rm -f crt0.o stdlib.o dhry_1.o dhry_2.o dhry.elf dhry.bin fw.hex dummy.hex dhry.dump
