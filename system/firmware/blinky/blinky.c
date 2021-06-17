volatile int *output_reg = (int*)0x10008;
volatile unsigned int *ms_count_reg = (unsigned int*)0x10008;

unsigned int time(void)
{
  return *ms_count_reg;
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
  return 0;
}
