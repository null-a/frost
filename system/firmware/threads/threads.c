#include "stdlib.h"

// The K on the input constraint indicates that the value can come
// from a 5-bit immediate. Such use of a literal ultimately generates
// a `csrrwi` instruction, somehow.

// https://github.com/riscv/riscv-test-env/blob/43d3d53809085e2c8f030d72eed1bdf798bfb31a/encoding.h#L211-L213
// https://gcc.gnu.org/onlinedocs/gcc/Machine-Constraints.html

#define swap_csr(reg, val) ({ unsigned long __tmp; \
      asm volatile ("csrrw %0, " #reg ", %1" : "=r"(__tmp) : "rK"(val)); \
      __tmp; })

#define MSTATUS_MIE 0x00000008

void bkg(void);

// Allocate space for 2 threads.
int threads[64];

// Space for the stack of the background thread.
#define STACK_SIZE 128
int bkg_stack[STACK_SIZE];

void enable_interrupts(void)
{
  swap_csr(mstatus, MSTATUS_MIE);
}

void init_threads(void)
{
  // Set-up initial thread state.
  threads[0] = 0;
  threads[32] = 1;
  threads[32+1] = (int)bkg; // Program counter.
  threads[32+3] = (int)(bkg_stack + STACK_SIZE - 4); // Stack pointer.
  // Initialise `tp` with a pointer to the main thread's data
  // structure.
  asm volatile ("mv tp, %0" :: "r"(threads));
  enable_interrupts();
}

int* switch_thread(int* tp)
{
  int id = tp[0];
  // Schedule the next thread switch. Note that time has elapsed since
  // the interrupt last fired, so this does't result in a thread
  // switch period of exactly the delta specified below.
  *mtimecmp = *mtime + 5000;
  // Toggle threads.
  int* next_thread_ptr = id==1 ? &threads[0] : &threads[32];
  return next_thread_ptr;
}

// It's important that this never returns, since the `ra` register of
// the background thread isn't set to anything sensible.
void bkg(void)
{
  int i, j = 0;
  for(;;) {
    j=j+2;
    printf("background: %d\n", j);
    for(i=0; i<500; i++);
  }
}

int main(void)
{
  int i, j = 0;
  init_threads();

  // Main thread continues...
  for(;;) {
    j++;
    printf("main: %d\n", j);
    for(i=0; i<250; i++);
  }

  return 0;
}
