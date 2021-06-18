#include <stdbool.h>

// The original definition of `swap_csr` has K on the input constraint
// to allow setting the CSR with a 5-bit immediate. I don't yet
// support CSRRWI so I don't include that here.

// https://github.com/riscv/riscv-test-env/blob/43d3d53809085e2c8f030d72eed1bdf798bfb31a/encoding.h#L211-L213
// https://gcc.gnu.org/onlinedocs/gcc/Machine-Constraints.html

#define swap_csr(reg, val) ({ unsigned long __tmp; \
      asm volatile ("csrrw %0, " #reg ", %1" : "=r"(__tmp) : "r"(val)); \
      __tmp; })

#define MSTATUS_MIE 0x00000008

int volatile * const output_reg = (int*)0x10008;
unsigned long long volatile * const mtime = (unsigned long long*)0x10020;
unsigned long long volatile * const mtimecmp = (unsigned long long*)0x10028;

void
__attribute__ ((interrupt))
__attribute__ ((section (".text.isr")))
handler(void)
{
  static bool state = false;
  *output_reg = state;
  state = !state;
  *mtimecmp = *mtime + 250000; // Will trigger interrupt in 0.25secs time.
}

void enable_interrupts(void)
{
  swap_csr(mstatus, MSTATUS_MIE);
}

int main(void)
{
  // Once interrupts are enabled, a timer interrupt will immediately
  // become pending because of the way `mtimecmp` is initialised in
  // hardware.
  enable_interrupts();
  for(;;);
  return 0;
}
