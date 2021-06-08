#include <stdarg.h>
#include "stdlib.h"

volatile int *uart_write_reg = (int*)0x10000;
volatile int *uart_read_reg = (int*)0x10004;
volatile unsigned int *ms_count_reg = (unsigned int*)0x10008;

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

void print_uint(unsigned int i)
{
  char buf[10]; // Build the string here in reverse
  char *ptr;
  for (ptr=buf;; ptr++) {
    *ptr = '0' + i % 10;
    i /= 10;
    if (i==0) break;
  }
  // Copy to an output buffer (with length >= 11).
  /* while (ptr >= buf) */
  /*   *dst++ = *ptr--; */
  /* *dst = '\0'; */
  while (ptr >= buf)
    putchar(*ptr--);
}

// Based in `minprintf` in K&R.
void printf(char *fmt, ...)
{
  va_list ap;
  char *p, *sval;
  int ival;
  va_start(ap, fmt);
  for (p = fmt; *p; p++) {
    if (*p != '%') {
      putchar(*p);
      continue;
    }
    switch (*++p) {
    case 'd':
      ival = va_arg(ap, int);
      print_uint(ival);
      break;
    case 's':
      sval = va_arg(ap, char*);
      puts(sval);
      break;
    case 'c':
      ival = va_arg(ap, int);
      putchar(ival);
      break;
    }
  }
  va_end(ap);
}

// Very simple memory allocation. See `alloc` in K&R.
#define ALLOCSIZE 128

static char allocbuf[ALLOCSIZE];
static char *allocp = allocbuf;

char* malloc(int n)
{
  char *p;
  if (allocbuf + ALLOCSIZE - allocp >= n) {
    p = allocp;
    allocp += n;
    return p;
  } else
    return 0;
}

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

// See K&R.
void strcpy(char *s, char *t)
{
  while (*s++ = *t++);
}

// See K&R.
int strcmp(char *s, char *t)
{
  for (; *s == *t; s++, t++)
    if (*s == '\0') /* == *t */
      return 0;
  return *s - *t;
}
