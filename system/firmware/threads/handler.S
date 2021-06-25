        ## Interrupt handler.

        .section .text.isr
_handler:

        ## Save registers.
        ## `tp` is a pointer to the current thread's data structure.
        ## (I'm currently saving/restoring) the `gp` register here, though that's not necessary.
        sw x1, 8(tp);
        sw x2, 12(tp);
        sw x3, 16(tp);
        sw x5, 20(tp);
        sw x6, 24(tp);
        sw x7, 28(tp);
        sw x8, 32(tp);
        sw x9, 36(tp);
        sw x10, 40(tp);
        sw x11, 44(tp);
        sw x12, 48(tp);
        sw x13, 52(tp);
        sw x14, 56(tp);
        sw x15, 60(tp);
        sw x16, 64(tp);
        sw x17, 68(tp);
        sw x18, 72(tp);
        sw x19, 76(tp);
        sw x20, 80(tp);
        sw x21, 84(tp);
        sw x22, 88(tp);
        sw x23, 92(tp);
        sw x24, 96(tp);
        sw x25, 100(tp);
        sw x26, 104(tp);
        sw x27, 108(tp);
        sw x28, 112(tp);
        sw x29, 116(tp);
        sw x30, 120(tp);
        sw x31, 124(tp);

        ## Save the program counter. (From before the interrupt fired.)
        csrrw x1, mepc, x0;
        sw x1, 4(tp);

        ## Call `switch_thread`, passing `tp` as argument.
        ## This returns the thread pointer for the next thread to run.
        mv a0, tp;
        call switch_thread;

        ## Store the new thread pointer.
        mv tp, a0;

        ## Restore the program counter.
        ## Here we place it in `mepc`, which will become the program counter after we do an `mret`.
        lw x1, 4(tp);
        csrrw x0, mepc, x1;

        ## Restore registers.
        lw x1, 8(tp);
        lw x2, 12(tp);
        lw x3, 16(tp);
        lw x5, 20(tp);
        lw x6, 24(tp);
        lw x7, 28(tp);
        lw x8, 32(tp);
        lw x9, 36(tp);
        lw x10, 40(tp);
        lw x11, 44(tp);
        lw x12, 48(tp);
        lw x13, 52(tp);
        lw x14, 56(tp);
        lw x15, 60(tp);
        lw x16, 64(tp);
        lw x17, 68(tp);
        lw x18, 72(tp);
        lw x19, 76(tp);
        lw x20, 80(tp);
        lw x21, 84(tp);
        lw x22, 88(tp);
        lw x23, 92(tp);
        lw x24, 96(tp);
        lw x25, 100(tp);
        lw x26, 104(tp);
        lw x27, 108(tp);
        lw x28, 112(tp);
        lw x29, 116(tp);
        lw x30, 120(tp);
        lw x31, 124(tp);

        mret
