#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # Check that lowest bit of rs1 + offset is set to zero.

        li TESTNUM, 2;
        la x1, l1;
        jalr x0, 1(x1);         # Will jump to junk if low bit not zeroed.
l1:
        auipc x2, 0;            # Load PC into x2
        bne x1, x2, fail;       # Explicitly check low bit of PC wasn't updated by jump.
        nop;

        li TESTNUM, 3;
        ## This checks that the lsb is cleared after doing `rs1+imm`, and not simply ignored.
        la x1, l2;
        addi x1, x1, 3;
        jalr x0, 1(x1);         # This ought to jump to l2 + 4.
l2:
        j fail
        nop;

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
