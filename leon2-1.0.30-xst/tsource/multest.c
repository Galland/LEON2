#include "test.h"
#include "leon.h"

struct mulcase {
	int	fac1;
	int	fac2;
	int	res;
};

volatile struct mulcase mula[] = { { 2, 3, 6}, { 2, -3, -6}, { 0,  1, 0},
	{ 0, -1, 0}, {  1, -1, -1}, { -1,  1, -1}, { -2,  3, -6},
	{ -2, -3, 6}, {  0,  0, 9}};

static int mulscctmp = 0xfffff000;

multest()
{
	int i = 0;

	report(MUL_TEST);
	if (mulscc_test() != 0x123) fail(1);

	/* skip test if divider disabled */
	if (!((lr->leonconf >> MUL_CONF_BIT) & 1)) return(0);	
	
	while (mula[i].res != 9) {
	    if ((mula[i].fac1 * mula[i].fac2) - mula[i].res) fail(1);
	    i++;
	}
	if (!mulpipe()) fail(2);
	if (!((lr->leonconf >> MAC_CONF_BIT) & 1)) return(0);	
	if (!macpipe()) fail(3);
}

mulscc_test () {
asm ("
	.text

	addcc %g0, %g0, %g0
	set   mulscctmp, %o2
	mov   0, %o0			
	mov   0x246, %o1	
	mov	%g0, %y
	nop; nop; nop
	ld    [%o2], %o0
	mulscc %o1, %o0, %o0
	retl
	nop
	");
}

mulpipe () {
asm ("
	.text

	mov	%g0, %y
	set	1, %o0
	orcc	%g0, 1, %g0	! clear icc
	umulcc	%g0, 1, %g0	! set Z
	bne	1f
	nop
	umulcc	%o0, -1, %g0	! set N
	bge	1f
	nop
	smulcc	%o0, -1, %g0	! set N and Y
	mov	%y, %o1
	subcc	%o1, -1, %g0
	bne	1f
	nop
	umulcc	%o0, -1, %g0	! set N
	mov	%psr, %o1
	srl	%o1, 20, %o1
	and	%o1, 0x0f, %o1
	subcc	%o1, 8, %g0
	bne	1f
	nop

	retl
	or	%g0, 1, %o0

1:
	retl
	mov	%g0, %o0
	");
}

macpipe () {
asm ("
	.text

	set 	0x55555555, %o1		! test %asr18
	mov	%o1, %asr18
	nop; nop; nop
	mov	%asr18, %o2
	subcc	%o1, %o2, %g0
	bne	1f
	nop
	not	%o1
	mov	%o1, %asr18
	nop; nop; nop
	mov	%asr18, %o2
	subcc	%o1, %o2, %g0
	bne	1f
	nop

	set	0xffff, %o0
	mov	%g0, %asr18
	mov	%g0, %y
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	mov	%y, %o4
	mov	%asr18, %o3
	set	0xfff00008, %o2
	subcc	%o1, %o2, %g0
	bne	1f
	subcc	%o1, %o3, %g0
	bne	1f
	subcc	%o4, 0x07, %g0
	bne	1f

	set	0xffff, %o0
	mov	%g0, %asr18
	mov	%g0, %y
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	mov	%y, %o4
	mov	%asr18, %o3
	subcc	%o1, 8, %g0
	bne	1f
	subcc	%o1, 8, %g0
	bne	1f
	subcc	%o4, 0, %g0
	bne	1f
	
	retl
	or	%g0, 1, %o0

1:
	retl
	mov	%g0, %o0

	");
}

int ddd[8] = {0,0,0,0,0,0,0,0};
