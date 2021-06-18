#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

        ## Test case 1
        li TESTNUM, 1;
        li x1, 0x55;
        li x2, 0x55;
        csrrw x0, mepc, x1;
        li x1, 0;
        csrrw x1, mepc, x1;
        bne x1, x2, fail;

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
