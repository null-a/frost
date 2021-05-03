#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # Check that `sb` stores only the lowest 8 bits.

  TEST_CASE( 2, x5, 0xefefefac, \
    la  x1, tdat; \
    li  x2, 0xddddddac; \
    sb x2, 0(x1); \
    lw x5, 0(x1); \
  )

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

tdat:
tdat1:  .byte 0xef
tdat2:  .byte 0xef
tdat3:  .byte 0xef
tdat4:  .byte 0xef

RVTEST_DATA_END
