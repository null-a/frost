#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # Check that lowest bit of rs1 + offset is set to zero.

        li TESTNUM, 2;
        la x1, l1;
        jalr x0, 1(x1);         # Will jump to junk if low bit not zeroed.
l1:
        nop;

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
