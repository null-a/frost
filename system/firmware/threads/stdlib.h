static unsigned long long volatile * const mtime = (unsigned long long*)0x10020;
static unsigned long long volatile * const mtimecmp = (unsigned long long*)0x10028;
int getchar();
void putchar(int c);
void puts(char *s);
void print_uint(unsigned int i);
void printf(char *fmt, ...);
char *malloc(int n);
unsigned int time(void);
void sleep(unsigned int ms);
void strcpy(char *s, char *t);
int strcmp(char *s, char *t);
