.PHONY: all clean

objs = $(basename $(wildcard *.S))
targets = $(addsuffix .hex, $(objs)) $(addsuffix .dump, $(objs))

all: $(targets)

%.o: %.S riscv_test.h test_macros.h
	riscv32-unknown-elf-gcc -c $<

%.elf: %.o
	riscv32-unknown-elf-ld $< -Ttext 0x0 --no-relax -o $@

%.bin: %.elf
	riscv32-unknown-elf-objcopy -O binary $< $@
	chmod -x $@

%.hex: %.bin
	python3 ../src/bin2hex.py $< > $@

%.dump: %.elf
	riscv32-unknown-elf-objdump -d $< > $@

clean:
	rm -f *.o *.elf *.bin *.dump
