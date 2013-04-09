#include "leon.h"
#define RAMSIZE 0x40000
#define RAMEND (CRAM + RAMSIZE)

	.seg	"text"
	.proc	0
	.align	4
	.global _hardreset
_hardreset:
por:

	flush
	set 0x10c0, %g1		! init IU
	mov %g1, %psr
	mov %g0, %wim
	mov %g0, %tbr
	mov %g0, %y
	nop
	
	set PREGS, %g7		! on-chip register base address
	set  0x81000f, %g1
	st %g1, [%g7 + CCTRL]

	ld [%g7 + ECTRL], %g1
	and %g1, 0x100, %g1
	sll %g1, 1, %g2
	or %g1, %g2, %g1
	set 0x0f0000, %g2
	or %g1, %g2, %g1
	st %g1, [%g7 + ECTRL]

	ld [%g7 + MCFG1], %g1
	and %g1, 0x3ff, %g1
	st %g1, [%g7 + MCFG1]
	and %g1, 0x300, %g1

	ld [%g7 + IOREG], %g2
	srl %g2, 4, %g3
	and %g3, 3, %g3
	or %g1, %g3, %g1
	set 0x04080000, %g3 	! initialise memory config registers
	or %g3, %g1, %g1
	st %g1, [%g7 + MCFG1]

	sll %g2, 4, %g3
	and %g3, 0x70, %g1
	and %g2, 0x0c0, %g3
	srl %g3, 4, %g3
	or %g3, %g1, %g1
	srl %g3, 2, %g3
	or %g3, %g1, %g1
	set 0x800, %g3
	or %g3, %g1, %g1
	andcc %g2, 3, %g0
	bne 1f
	nop
	add %g1, 0x200, %g1
1:
	set 0xd5384000, %g3
	or %g3, %g1, %g1
	st %g1, [%g7 + MCFG2]

	set	-1, %g3
	st %g0, [%g7 + FADDR]
	st %g0, [%g7 + MSTAT]
	st %g0, [%g7 + WPROT1]
	st %g0, [%g7 + WPROT2]
	st %g3, [%g7 + SRLD]
	st %g3, [%g7 + SCNT]
	st %g0, [%g7 + TCTRL0]
	st %g3, [%g7 + TRLD0]
	st %g3, [%g7 + TCNT0]
	st %g0, [%g7 + TCTRL1]
	st %g3, [%g7 + TRLD1]
	st %g3, [%g7 + TCNT1]
	st %g3, [%g7 + USCAL0]
	st %g3, [%g7 + UCTRL0]
	st %g0, [%g7 + USTAT0]
	st %g3, [%g7 + USCAL1]
	st %g3, [%g7 + UCTRL1]
	st %g0, [%g7 + USTAT1]
	st %g0, [%g7 + WPROT1]
	st %g0, [%g7 + WPROT2]
	st %g0, [%g7 + IOREG]
	st %g0, [%g7 + IOICONF]
	st %g0, [%g7 + IFORCE]
	st %g0, [%g7 + IMASK]
	st %g0, [%g7 + IPEND]
	st %g3, [%g7 + ICLEAR]
	st %g0, [%g7 + IMASK2]
	st %g0, [%g7 + IPEND2]
	st %g3, [%g7 + ICLEAR2]
	st %g0, [%g7 + ISTAT2]

	ld [%g7 + ECTRL], %g2	! if LEON-FT, then clear %asr16
	srl %g2, RFE_CONF_BIT, %g3
	andcc %g3, RFE_CONF_MASK, %g3
	be 2f
	nop
	mov %g0, %asr16

2:
	ld [%g7 + LCONF], %g2	! load LEON configuration register
	srl %g2, 20, %g3
	and %g3, 0x1f, %g3
	mov %g0, %g4
	mov %g0, %g5
	mov %g0, %g6
1:
	mov %g0, %l0
	mov %g0, %l1
	mov %g0, %l2
	mov %g0, %l3
	mov %g0, %l4
	mov %g0, %l5
	mov %g0, %l6
	mov %g0, %l7
	mov %g0, %o0
	mov %g0, %o1
	mov %g0, %o2
	mov %g0, %o3
	mov %g0, %o4
	mov %g0, %o5
	mov %g0, %o6
	mov %g0, %o7
	subcc %g3, 1, %g3
	bge 1b
	save

	srl %g2, FPU_CONF_BIT, %g3
	andcc %g3, FPU_CONF_MASK, %g0
	be 3f
	set	fsrinit, %g3
	ld	[%g3], %fsr
	ldd	[%g0], %f0
	ldd	[%g0], %f2
	ldd	[%g0], %f4
	ldd	[%g0], %f6
	ldd	[%g0], %f8
	ldd	[%g0], %f10
	ldd	[%g0], %f12
	ldd	[%g0], %f14
	ldd	[%g0], %f16
	ldd	[%g0], %f18
	ldd	[%g0], %f20
	ldd	[%g0], %f22
	ldd	[%g0], %f24
	ldd	[%g0], %f26
	ldd	[%g0], %f28
	ba	3f
	ldd	[%g0], %f30

3:
	set	0x40000000, %o1
	set	0x80000000, %o2
	set	0x80f003a7, %o3
	st	%o3, [%o2+0x28]

/*
	st	%o3, [%o1]
	lda	[%o1] 0, %g0
	st	%o3, [%o1]
	lda	[%o1] 0, %g0
	st	%o3, [%o1]
	lda	[%o1] 0, %g0
	st	%o3, [%o1]
	lda	[%o1] 0, %g0
	st	%o3, [%o1]
	call	0x40000000
	lda	[%o1] 0, %g0
	st	%o3, [%o1]
	lda	[%o1] 0, %g0

	set	1, %o3
	st	%o3, [%o2+4]
	set	2, %o3
	st	%o3, [%o2+4]
	st	%o3, [%o2+4]
	set	0x80100000, %o3
	st	%o3, [%o2+4]
     	nop
     	nop
     	nop
     	nop
	ldda	[%o1] 0, %o4
	set	0x76543210, %o3
	st	%o3, [%o1+0]
	st	%o3, [%o1+4]
	st	%o3, [%o1+8]
	std	%o2, [%o1+0]
	ld	[%o1+0], %o4
	ld	[%o1+4], %o4
1:
	ldda	[%o1] 0, %o4
	ldda	[%o1] 0, %o4
	call	0x40000000
	nop
	ba	1b
	st	%g0, [%o1+0x10]
	sth	%o3, [%o1+0x10]
	ld	[%o1+0x10], %o4
	st	%g0, [%o1+0x14]
	sth	%o3, [%o1+0x16]
	ld	[%o1+0x14], %o4
	st	%g0, [%o1+0x18]
	stub	%o3, [%o1+0x18]
	stub	%o3, [%o1+0x19]
	stub	%o3, [%o1+0x1a]
	stub	%o3, [%o1+0x1b]
	ld	[%o1+0x18], %o4
*/
/*
	set	0x20000000, %o1
	set	0x01234567, %o3
	st	%o3, [%o1+96]
	sth	%o3, [%o1+98]
	stb	%o3, [%o1+99]
	ld	[%o1+96], %o2
	st	%o2, [%o1+96]
	lduh	[%o1+96], %o3
	sth	%o3, [%o1+96]
	lduh	[%o1+98], %o3
	sth	%o3, [%o1+98]
	ldub	[%o1+96], %o4
	stb	%o4, [%o1+96]
	ldub	[%o1+97], %o4
	stb	%o4, [%o1+97]
	ldub	[%o1+98], %o4
	stb	%o4, [%o1+98]
	ldub	[%o1+99], %o4
	stb	%o4, [%o1+99]

	set 0xb0000000, %g1
	set 0x00000012, %g2
	st  %g2, [%g1+0x0c]
	set 0x0000000c, %g2
	st  %g2, [%g1+0x10]
	set 0x00000012, %g2
	st  %g2, [%g1+0x14]
	set 0x00400600, %g2
	st  %g2, [%g1+0x18]
	set 0x000f003f, %g2
	st  %g2, [%g1+0x1c]
	st  %g2, [%g1+0x44]
	set 0x00000002, %g2
	st  %g2, [%g1+0x20]
	set 0x00000008, %g2
	st  %g2, [%g1+0x40]

	set 0x40000000, %g2
	st  %g2, [%g1+0x404]
	st  %g2, [%g1+0x40c]
	st  %g2, [%g1+0x414]
	st  %g2, [%g1+0x41c]
	set 0x00888000, %g2
	st  %g2, [%g1+0x400]
	st  %g2, [%g1+0x408]
	st  %g2, [%g1+0x410]
	st  %g2, [%g1+0x418]
	

!	set 0x0001e0e3, %g2
	set 0x0001e003, %g2
	st  %g2, [%g1+0x00]
	set 128, %o1
	st %o1, [%o2 + 0x110]
	set 0x2000, %o1
	st %o1, [%o2 + 0x104]
	st %o1, [%o2 + 0x114]
	ld [%o2 + 0x114], %g0
	ld [%o2 + 0x11C], %g0
	set 0x80008000, %o3
	set 0x8000c000, %o4
	ld [%o3 +7*4], %l1
	ld [%o4 +7*4], %l2
	set 0x80000000, %o5
	set -1, %o1
	st %o1, [%o5]
	ld [%o5], %l2

*/

	mov	2, %g1
	mov	%g1, %wim
	set 0x10e0, %g1		! enable traps
	mov %g1, %psr
	nop; nop; nop;
!	set 0x8f004000 - 16, %g3
	set CRAM + (192*1024) - 16, %g3
!	set SDRAM + (256*1024) - 16, %g3
	mov	%g3, %fp
	sub	%g3, 96, %sp

	set	CRAM, %g1
/*
1:	ld	[%g1+0x000], %g2
	ld	[%g1+0x804], %g2
	ld	[%g1+0x800], %g2
	ld	[%g1+0xc00], %g2
	ld	[%g1+0x400], %g2
	ld	[%g1+0x408], %g2
	ba	1b
	nop
*/

	jmp	%g1
	nop

fsrinit:
	.word 0
.align	32
