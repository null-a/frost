        .text
        .global _start
_start:
        li sp, 2044             # Set the stack pointer
        call main
        ebreak
