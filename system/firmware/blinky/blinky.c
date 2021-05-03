volatile int *output_reg = (int*)0x10008;

/* This isn't a great way to implement this, since we only get the
   hoped for behaviour when the compiler doesn't optimize away the
   loops. Better read the hardware timer? */

int main(void)
{
  int i;
  for(;;) {
    *output_reg = 1;
    for(i=0; i<100000; i++);
    *output_reg = 0;
    for(i=0; i<100000; i++);
    *output_reg = 1;
    for(i=0; i<100000; i++);
    *output_reg = 0;
    for(i=0; i<400000; i++);
  }
  return 0;
}
