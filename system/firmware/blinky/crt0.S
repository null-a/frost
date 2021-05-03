        .text
        .global _start
_start:

        .option push
        .option norelax
        la gp, __global_pointer$
        .option pop
        li sp, (14*1024-4)      # Set the stack pointer
        call main
        ebreak
