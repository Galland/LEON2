#include "leon.h"
#include "test.h" 

#define CCTRL_IFP (1<<15)
#define CCTRL_DFP (1<<14)

ramfill()
{
	int ilinesz, dlinesz, dbytes, ibytes, itmask, dtmask, isets, dsets; 
	int cachectrl, leonconf;
	leonconf = lr->leonconf;
	isets = ((lr->cachectrl >> 26) & 3) + 1;
	dsets = ((lr->cachectrl >> 24) & 3) + 1;
	ilinesz = 1 << (((leonconf >> 15) & 3) + 2);
	ibytes = (1 << (((leonconf >> 17) & 7) + 10)) * isets;
	dlinesz = 1 << (((leonconf >> 10) & 3) + 2);
	dbytes = (1 << (((leonconf >> 12) & 7) + 10)) * dsets;
	lr->cachectrl = 0x10000;        /* disable icache & dcache */
	ifill(ibytes);
	dfill(dbytes);
	flush();
	lr->cachectrl = 0x1000f;        /* enable icache & dcache */
}

ifill(int bytes)
{
	asm ("

	subcc	%o0, 4, %o0
1:

	sta	%g0, [%o0] 0xd
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xd
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xd
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xd
	sta	%g0, [%o0] 0xc
	subcc	%o0, 4, %o0
	bg	1b
	nop
	");
}

dfill(int bytes, int dlinesz)
{
	asm ("
	subcc	%o0, 4, %o0
1:

	sta	%g0, [%o0] 0xf
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xf
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xf
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xf
	sta	%g0, [%o0] 0xe
	subcc	%o0, 4, %o0
	bg	1b
	nop

	");
}

ramtest()
{
	volatile double mrl[1024 + 8];
	int i; 
	int ilinesz, dlinesz, dbytes, ibytes, itmask, dtmask, isets, dsets; 
	int leonconf;

	flush();
	lr->cachectrl |= 0x0f;        /* enable icache & dcache */

	report(DPRAM_TEST);
	if (dpramtest() != 1) fail(13);

	report(CRAM_TEST);
	leonconf = lr->leonconf;

	isets = ((lr->cachectrl >> 26) & 3) + 1;
	dsets = ((lr->cachectrl >> 24) & 3) + 1;
	ilinesz = 1 << (((leonconf >> 15) & 3) + 2);
	ibytes = (1 << (((leonconf >> 17) & 7) + 10)) * isets;
	itmask = (ilinesz - 1) | (0x80000000 - ibytes);
	dlinesz = 1 << (((leonconf >> 10) & 3) + 2);
	dbytes = (1 << (((leonconf >> 12) & 7) + 10)) * dsets;
	dtmask = (dlinesz - 1) | (0x80000000 - dbytes);

	while(lr->cachectrl & (CCTRL_IFP|CCTRL_DFP) ) {} /* wait for flush to complete */

	/* dcache data ram */

	if (ddramtest1(dbytes, mrl,0x55555555)) fail(1);
	if (ddramtest2(dbytes, mrl,0xaaaaaaaa)) fail(2);

	lr->cachectrl = 0x10000;        /* disable icache & dcache */

	/* dcache tag ram */

	if (dtramtest(dbytes, (0xaaaaaa00 & dtmask), dtmask, dlinesz,
	    0xaaaaaaaa)) fail(3);
	if (dtramtest(dbytes, (0x55555500 & dtmask), dtmask, dlinesz,
	    0x55555555)) fail(4);

	/* icache data ram */

	if (idramtest(ibytes, 0x55555555)) fail(5);
	if (idramtest(ibytes, 0xaaaaaaaa)) fail(6);

	/* icache tag ram */

	if (itramtest(ibytes, itmask, ilinesz, 0xaaaaaaaa)) fail(7);
	if (itramtest(ibytes, itmask, ilinesz, 0x55555555)) fail(8);
	flush();
	lr->cachectrl = 0x1000f;        /* enable icache & dcache */

}



/* test dcache data ram */
ddramtest1(int bytes, int *buf, int init)
{
	asm ("

	mov	%o0, %o4
	mov	%o2, %o3
1:
	subcc	%o4, 8, %o4
	bg 1b
	std	%o2, [%o4 + %o1]

	mov	%o0, %o4
1:
	subcc	%o4, 8, %o4
	bg 1b
	ldd	[%o4 + %o1], %g0

	mov	%o0, %o4
	subcc	%o4, 4, %o4
	ld	[%o4 + %o1], %o3
2:
	subcc	%o3, %o2, %g0
	bne 	6f
	subcc	%o4, 4, %o4
	bg,a 2b
	ld	[%o4 + %o1], %o3

	retl
	mov	0, %o0

6: 	mov	1, %o0

	");
}

/* test dcache data ram */
ddramtest2(int bytes, int *buf, int init)
{
	asm ("

	mov	%o0, %o4
	mov	%o2, %o3
1:
	subcc	%o4, 8, %o4
	bg 1b
	std	%o2, [%o4 + %o1]

	mov	%o0, %o4
	subcc	%o4, 4, %o4
	ld	[%o4 + %o1], %o3
2:
	subcc	%o3, %o2, %g0
	bne 	6f
	subcc	%o4, 4, %o4
	bg,a 2b
	ld	[%o4 + %o1], %o3


	retl
	mov	0, %o0

6: 	mov	1, %o0

	");

}

/* test icache data ram */
idramtest(int bytes, int init)
{
	asm ("

	mov	%o0, %o4	! init data ram
	subcc	%o4, 4, %o4
	sta	%o1, [%o4] 0xd
1:
	lda	[%o4] 0xd, %o5
	subcc	%o5, %o1, %g0
	bne 	6f
	subcc	%o4, 4, %o4
	bg 1b
	sta	%o1, [%o4] 0xd

	retl
	mov	0, %o0

6: 	mov	1, %o0
	");

}


itramtest(int bytes, int mask, int linesz, int init)
{
	asm ("

	mov	%o0, %o5	! init data ram
	subcc	%o5, %o2, %o5
	sta	%o3, [%o5] 0xc
1:
	lda	[%o5] 0xc, %o4
	xor  	%o4, %o3, %o4
	andcc	%o4, %o1, %o4
	bne 	6f
	subcc	%o5, %o2, %o5
	bg 1b
	sta	%o3, [%o5] 0xc

	retl
	mov	0, %o0

6: 	mov	1, %o0
	");
}

dtramtest(int bytes, int addr, int mask, int linesz, int init)
{
	asm ("

	mov	%o0, %o5	! init data ram
	subcc	%o5, %o3, %o5
	sta	%o4, [%o1 + %o5] 0xe

1:
	lda	[%o1 + %o5] 0xe, %g2
	xor  	%g2, %o4, %g2
	andcc	%g2, %o2, %g2
	bne 	6f
	subcc	%o5, %o3, %o5
	bg 1b
	sta	%o4, [%o1 + %o5] 0xe

	retl
	mov	0, %o0

6: 	mov	1, %o0
	");
}



asm ("

	.text
	.align 4
	.global _dpramtest, dpramtest, regbuf
	.proc	04

_dpramtest:
dpramtest:


	save %sp, -96, %sp

	set 0x80000000, %l0
	ld [%l0 + 0x08], %g2	! get configuration status
	srl %g2, 30, %g3
	andcc %g3, 3, %g3
	be 1f
	nop
	mov	%asr16, %g3	! skip tests if err-injection is on
	andcc %g4, 0xe00, %g3
	bne testok
	nop
	mov 	%g0, %asr16	! clear error counters

	! flush all register windows (maximum 32)
1:
	set	0x80000024, %l2
	ld	[%l2], %l2
	srl	%l2, 20, %g5
	and	%g5, 0x1f, %g5
	mov	%g5, %g6
2:
	save %sp, -96, %sp
	subcc	%g5, 1, %g5
	bge	2b
	nop
3:
	restore
	subcc	%g6, 1, %g6
	bge	3b
	nop

	! save global and input registers

	nop; nop
	set	regbuf, %l0
	mov	%psr, %l1
	st	%l1, [%l0]
	st	%g1, [%l0+4]
	std	%g2, [%l0+8]
	std	%g4, [%l0+16]
	std	%g6, [%l0+24]
	std	%i0, [%l0+32]
	std	%i2, [%l0+40]
	std	%i4, [%l0+48]
	std	%i6, [%l0+56]
	mov	%wim, %l2
	st	%l2, [%l0+64]

	mov	%g0, %wim
	andn	%l1, 0x1f, %l2
	mov	%l2, %psr
	nop; nop; nop
	
	! test gloabal registers
	! note that test have to be done twice, once for each dpram-half

	set	0x55555555, %g1	! test 0x55555555 in global regs, dpram1
7:
	mov	%g1, %g2
	mov	%g1, %g3
	mov	%g1, %g4
	mov	%g1, %g5
	mov	%g1, %g6
	mov	%g1, %g7

	subcc	%g1, %g2, %g0
	bne	fail
	subcc	%g1, %g3, %g0
	bne	fail
	subcc	%g1, %g4, %g0
	bne	fail
	subcc	%g1, %g5, %g0
	bne	fail
	subcc	%g1, %g6, %g0
	bne	fail
	subcc	%g1, %g7, %g0
	bne	fail
	subcc	%g2, %g1, %g0
	bne	fail
	subcc	%g3, %g1, %g0
	bne	fail
	subcc	%g4, %g1, %g0
	bne	fail
	subcc	%g5, %g1, %g0
	bne	fail
	subcc	%g6, %g1, %g0
	bne	fail
	subcc	%g7, %g1, %g0
	bne	fail

	andcc	%g1, 0x0ff, %g7
	xorcc	%g7, 0x55, %g0
	be	7b
	xor	%g1, -1, %g1

	! fill all windowed registers with 0x55555555/0xaaaaaaaa
	set	0x55555555, %g2
	mov	%g0, %g3
	set	0x80000024, %g3
	ld	[%g3], %g3
	srl	%g3, 20, %g4
	and	%g4, 0x1f, %g4
	mov	%g4, %g3
4:
	mov	%g2, %l0
	mov	%g2, %l1
	mov	%g2, %l2
	mov	%g2, %l3
	mov	%g2, %l4
	mov	%g2, %l5
	mov	%g2, %l6
	mov	%g2, %l7
	mov	%g2, %o0
	mov	%g2, %o1
	mov	%g2, %o2
	mov	%g2, %o3
	mov	%g2, %o4
	mov	%g2, %o5
	mov	%g2, %o6
	mov	%g2, %o7
	save
	subcc	%g3, 1, %g3
	bge	4b
	nop
	
	! check values

	mov	%g4, %g3
	mov	%g0, %g1
5:
	subcc	%l0, %g2, %g0	! dpram1
	bne	fail
	subcc	%l1, %g2, %g0
	bne	fail
	subcc	%l2, %g2, %g0
	bne	fail
	subcc	%l3, %g2, %g0
	bne	fail
	subcc	%l4, %g2, %g0
	bne	fail
	subcc	%l5, %g2, %g0
	bne	fail
	subcc	%l6, %g2, %g0
	bne	fail
	subcc	%l7, %g2, %g0
	bne	fail
	subcc	%o0, %g2, %g0
	bne	fail
	subcc	%o1, %g2, %g0
	bne	fail
	subcc	%o2, %g2, %g0
	bne	fail
	subcc	%o3, %g2, %g0
	bne	fail
	subcc	%o4, %g2, %g0
	bne	fail
	subcc	%o5, %g2, %g0
	bne	fail
	subcc	%o6, %g2, %g0
	bne	fail
	subcc	%o7, %g2, %g0
	bne	fail
	nop
	
	subcc	%g2, %l0, %g0	! dpram2
	bne	fail
	subcc	%g2, %l1, %g0
	bne	fail
	subcc	%g2, %l2, %g0
	bne	fail
	subcc	%g2, %l3, %g0
	bne	fail
	subcc	%g2, %l4, %g0
	bne	fail
	subcc	%g2, %l5, %g0
	bne	fail
	subcc	%g2, %l6, %g0
	bne	fail
	subcc	%g2, %l7, %g0
	bne	fail
	subcc	%g2, %o0, %g0
	bne	fail
	subcc	%g2, %o1, %g0
	bne	fail
	subcc	%g2, %o2, %g0
	bne	fail
	subcc	%g2, %o3, %g0
	bne	fail
	subcc	%g2, %o4, %g0
	bne	fail
	subcc	%g2, %o5, %g0
	bne	fail
	subcc	%g2, %o6, %g0
	bne	fail
	subcc	%g2, %o7, %g0
	bne	fail

	save
	subcc	%g3, 1, %g3
	bge	5b
	nop
	
	and	%g2, 0x0ff, %g6	! repeat test with 0xaaaaaaaa
	subcc	%g6, 0xaa, %g0
	be	cbtest
	add	%g2, %g2, %g2
	ba	4b
	mov	%g4, %g3

! the above test all set the edac checkbits to 0x0c, redo the
! test with cb = 0x73 to check for both stuck-1 and stuck-0 errors

cbtest:
	set 0x80000000, %l0
	ld [%l0 + 0x08], %g2	! get configuration status
	srl %g2, 30, %g3
	andcc %g3, 3, %g3
	be testok
	nop
	mov	%asr16, %g3	! skip cb tests if errors have been seen
	andcc %g4, 0xe00, %g3
	bne fail

	! fill all windowed registers with 0x80000090 (cb = 0x73)
	mov %g0, %asr16		! clear error counters
	set	0x80000090, %g2
	mov	%g4, %g3
4:
	mov	%g2, %l0
	mov	%g2, %l1
	mov	%g2, %l2
	mov	%g2, %l3
	mov	%g2, %l4
	mov	%g2, %l5
	mov	%g2, %l6
	mov	%g2, %l7
	mov	%g2, %o0
	mov	%g2, %o1
	mov	%g2, %o2
	mov	%g2, %o3
	mov	%g2, %o4
	mov	%g2, %o5
	mov	%g2, %o6
	mov	%g2, %o7
	save
	subcc	%g3, 1, %g3
	bge	4b
	nop
	
	! check values

	mov	%g4, %g3
5:
	addcc	%l0, %l0, %g1	! dpram1 & dpram2
	addxcc	%l1, %l1, %g1
	addxcc	%l2, %l2, %g1
	addxcc	%l3, %l3, %g1
	addxcc	%l4, %l4, %g1
	addxcc	%l5, %l5, %g1
	addxcc	%l6, %l6, %g1
	addxcc	%l7, %l7, %g1
	addxcc	%o0, %o0, %g1
	addxcc	%o1, %o1, %g1
	addxcc	%o2, %o2, %g1
	addxcc	%o3, %o3, %g1
	addxcc	%o4, %o4, %g1
	addxcc	%o5, %o5, %g1
	addxcc	%o6, %o6, %g1
	addxcc	%o7, %o7, %g1
	save
	subcc	%g3, 1, %g3
	bge	5b
	nop

	mov %asr16, %l2
	andcc %l2, 0xe00, %l2
	bne	fail		! fail if correction was found

testok:
	set	regbuf, %l0
	mov	1, %o0
	ba	exit
	st	%o0, [%l0+32]
fail:
	set	regbuf, %l0
	ba	exit
	st	%g0, [%l0+32]

exit:

	! restore state

	set	regbuf, %g1
	ld	[%g1], %g2
	mov	%g2, %psr
	nop; nop; nop
	ldd	[%g1+8], %g2
	ldd	[%g1+16], %g4
	ldd	[%g1+24], %g6
	ldd	[%g1+32], %i0
	ldd	[%g1+40], %i2
	ldd	[%g1+48], %i4
	ldd	[%g1+56], %i6
	ld	[%g1+64], %l2
	ld	[%g1+4], %g1
	mov	%l2, %wim
	nop; nop; nop

last:

	ret
	restore
");
