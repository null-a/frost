#include "stdlib.h"

int main(void)
{
  printf("%d\n", time());
  sleep(10);
  printf("%d\n", time());
  sleep(10);
  printf("%d", time());
  return 0;
}
