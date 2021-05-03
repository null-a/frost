#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # Check that the JAL offset is sign extended

        li TESTNUM, 2;
        j l2;
        j fail;
l1:
        j end;
        j fail;
l2:
        jal x0, l1;             # negative offset
        j fail;
end:
        nop;

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
