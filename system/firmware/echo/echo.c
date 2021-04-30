volatile int *uart_write_reg = (int*)0x10000;
volatile int *uart_read_reg = (int*)0x10004;

void putchar(int c)
{
  // Ensure there's room in the tx buffer.
  while(*uart_write_reg);
  *uart_write_reg = c;
}

int getchar()
{
  int reg, isempty;
  for(;;) {
    reg = *uart_read_reg;
    isempty = reg >> 8;
    if (!isempty)
      return reg & 0xff;
  }
}

int main(void)
{
  for(;;) {
    putchar(getchar());
  }
  return 0;
}
