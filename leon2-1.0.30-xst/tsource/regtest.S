#include "leon.h"
#include "test.h"

	.text
	.align 4
	.global _regtest, regtest
	.proc	04

_regtest:
regtest:


	save %sp, -96, %sp

	set PREGS, %l0
	ld [%l0 + ECTRL], %g2	! get configuration status
	srl %g2, RFE_CONF_BIT, %g3
	andcc %g3, 3, %g3
	be 1f
	nop
	mov	%asr16, %g4	! skip EDAC test if err-injection is on
	andcc %g4, 0xe00, %g4
	bne 1f
	subcc %g3, 3, %g0
	mov 0x6, %l1
	be,a 	2f
	mov 0x32, %l1
2:
	mov %l1, %asr16		! regfile EDAC test mode enable
	mov %g0, %l3
	mov %g0, %asr16	
	or %l3, 0, %l4
	mov %asr16, %l5
	or %l3, 0, %l6
	mov %asr16, %l7
	subcc %l4, 0, %g0	! %l4 should be zero
	bne err1
	andcc %l5, 0xe00, %l5	! data-forwarding should not trigger EDAC error
	subcc %l5, %g0, %g0	
	bne err1
	subcc %l6, 0, %g0	! %l6 should be 0 (corrected)
	bne err1
	and %l7, 0xe00, %l7
	subcc %l7, 0x200, %g0	! error counter should be incremented
	bne err1
	nop

	mov %g0, %l0		! correctable EDAC error in LD
	mov %l1, %asr16		
	mov %g0, %l3	
	mov %g0, %asr16	
	ldd [%g0], %l4
	mov %g0, %l6
	mov %g0, %l7
	ld [%l3], %l6
	ld [%l3 + 4], %l7
	cmp %l4, %l6
	bne err1
	cmp %l5, %l7
	bne err1
	nop
	mov %asr16, %l2
	and %l2, 0xe00, %l2
	subcc %l2, 0x200, %g0	! error counter should be incremented
	bne err1
	nop

	mov %g0, %l0		! 2 correctable EDAC errors in LD
	mov %l1, %asr16		
	mov %g0, %l2	
	mov %g0, %l3	
	mov %g0, %asr16	
	ldd [%g0], %l4
	mov %g0, %l6
	mov %g0, %l7
	ld [%l3 + %l2], %l6
	ld [%l3 + 4], %l7
	cmp %l4, %l6
	bne err1
	cmp %l5, %l7
	bne err1
	nop
	mov %asr16, %l2
	and %l2, 0xe00, %l2
	subcc %l2, 0x200, %g0	! error counter should be incremented
	bl err1
	nop

	set 0x40000000, %l0		! 4 correctable EDAC errors in STD
	ldd [%l0], %l6
	set 0x41000000, %l0
	mov %l1, %asr16		
	mov %l0, %l2	
	mov %g0, %l3	
	mov %g0, %l6	
	mov %g0, %l7	
	mov %g0, %asr16	
	std %l6, [%l2 + %l3]
	mov %g0, %l6
	mov %g0, %l7
	ldd [%l3 + %l2], %l4
	cmp %l4, %l6
	bne err1
	cmp %l5, %l7
	bne err1
	nop
	mov %asr16, %l2
	and %l2, 0xe00, %l2
	subcc %l2, 0x400, %g0	! error counter should be incremented
	ble err1
	nop
	ba 1f
	nop

err1:
	ba last
	mov %g0, %i0
	


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

	! test gloabal registers

	mov	8, %g0
	mov	1, %g1
	mov	2, %g2
	mov	3, %g3
	mov	4, %g4
	mov	5, %g5
	mov	6, %g6
	mov	7, %g7
	mov	%g0, %wim
	andn	%l1, 0x1f, %l2
	mov	%l2, %psr
	nop; nop; nop
	
	! fill all registers
	set	0x01010101, %g1
	mov	%g0, %g2
	mov	%g0, %g3
	set	0x80000024, %g3
	ld	[%g3], %g3
	srl	%g3, 20, %g4
	and	%g4, 0x1f, %g4
	mov	%g4, %g3
4:
	mov	%g2, %l0
	add	%g1, %g2, %g2
	mov	%g2, %l1
	add	%g1, %g2, %g2
	mov	%g2, %l2
	add	%g1, %g2, %g2
	mov	%g2, %l3
	add	%g1, %g2, %g2
	mov	%g2, %l4
	add	%g1, %g2, %g2
	mov	%g2, %l5
	add	%g1, %g2, %g2
	mov	%g2, %l6
	add	%g1, %g2, %g2
	mov	%g2, %l7
	add	%g1, %g2, %g2
	mov	%g2, %o0
	add	%g1, %g2, %g2
	mov	%g2, %o1
	add	%g1, %g2, %g2
	mov	%g2, %o2
	add	%g1, %g2, %g2
	mov	%g2, %o3
	add	%g1, %g2, %g2
	mov	%g2, %o4
	add	%g1, %g2, %g2
	mov	%g2, %o5
	add	%g1, %g2, %g2
	mov	%g2, %o6
	add	%g1, %g2, %g2
	mov	%g2, %o7
	add	%g1, %g2, %g2
	save
	subcc	%g3, 1, %g3
	bge	4b
	nop
	
	! check values

	set	0x01010101, %g1
	mov	%g0, %g2
	mov	%g4, %g3
5:
	cmp	%l0, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l1, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l2, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l3, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l4, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l5, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l6, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l7, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o0, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o1, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o2, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o3, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o4, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o5, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o6, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o7, %g2
	bne	fail
	add	%g1, %g2, %g2
	
	save
	subcc	%g3, 1, %g3
	bge	5b
	nop
	


	subcc	%g0, 0, %g0
	bne	fail
	subcc	%g3, -1, %g0
	bne	fail
	subcc	%g5, 5, %g0
	bne	fail
	subcc	%g6, 6, %g0
	bne	fail
	subcc	%g7, 7, %g0
	bne	fail
	nop

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

	.align 8
.common   regbuf, 80,"bss"

.align 32
