volatile int *uart_write_reg = (int*)0x10000;

void putchar(int c)
{
  // Ensure there's room in the tx buffer.
  while(*uart_write_reg);
  *uart_write_reg = c;
}

void puts(char *s)
{
  char c;
  while (c = *(s++))
    putchar(c);
}

int main(void)
{
  puts("hello, world!");
  return 0;
}
