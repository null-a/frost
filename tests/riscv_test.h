#ifndef _ENV_PICORV32_TEST_H
#define _ENV_PICORV32_TEST_H

#define RVTEST_RV32U
#define TESTNUM x28

#define RVTEST_CODE_BEGIN		\
	.text;				\
	.global _start;                 \
_start:                                 \
        nop;                            \

#define RVTEST_PASS			\
        li x31, 0x55;                   \
        ebreak;                         \

#define RVTEST_FAIL			\
        li x31, 0xaa;                   \
        ebreak;                         \

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN .balign 4;
#define RVTEST_DATA_END

#endif
