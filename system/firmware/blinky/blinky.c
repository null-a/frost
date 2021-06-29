int volatile * const output_reg = (int*)0x10008;
unsigned long long volatile * const mtime = (unsigned long long*)0x10020;

unsigned int time(void)
{
  return *(unsigned int*)mtime;
}

void sleep(unsigned int ms)
{
  unsigned int start;
  start = time();
  while (time() - start < ms);
}

int main(void)
{
  for(;;) {
    *output_reg = 1;
    sleep(100000);
    *output_reg = 0;
    sleep(100000);
    *output_reg = 1;
    sleep(100000);
    *output_reg = 0;
    sleep(400000);
  }
}
