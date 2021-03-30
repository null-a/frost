        .text
        .global _start
_start:
        li sp, (32*1024-4)      # Set the stack pointer
        call main
        ebreak
