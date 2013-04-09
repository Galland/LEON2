/*
 * locore.s for ERC32
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 675
 * Mass Ave, Cambridge, MA 02139, USA.
 *
 */
 
#include "leon.h"
#include "test.h"

/* The traptable has to be the first code in a boot PROM. */

/* Entry for traps which jump to a programmer-specified trap handler.  */
#define TRAP(H)  mov %psr, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); mov %tbr, %l3;
#define TRAPL(H)  mov %g0, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); nop;
#define SRMMU_TFAULT rd %psr, %l0; rd %wim, %l3; b srmmu_fault; mov 1, %l7;
#define SRMMU_DFAULT rd %psr, %l0; rd %wim, %l3; b srmmu_fault; mov 0, %l7;

/* Unexcpected trap will halt the processor by forcing it to error state */
#define BAD_TRAP ta 0; nop; nop; nop;

/* Software trap. Treat as BAD_TRAP for the time being... */
#define SOFT_TRAP BAD_TRAP

#define PSR_INIT   0x10c0	/* Disable traps, set s and ps */
#define WIM_INIT   2
#define SP_INIT	   0x023ffff0

WINDOWSIZE = (16 * 4)
ARGPUSHSIZE = (6 * 4)
ARGPUSH = (WINDOWSIZE + 4)
MINFRAME = (WINDOWSIZE + ARGPUSHSIZE + 4)
#define STACK_ALIGN	8
#define SA(X)	(((X)+(STACK_ALIGN-1)) & ~(STACK_ALIGN-1))

  .seg    "text"
  .global _trap_table, start, _start, _hardreset, test1, fsr1, fq1

  /* Hardware traps */
start:
_trap_table:
_hardreset:
  TRAPL(_reset);		! 00 reset trap 
  SRMMU_TFAULT			! 01 instruction_access_exception (in mmu_asm.S)
  TRAP(_skipn);			! 02 illegal_instruction
  BAD_TRAP;			! 03 priveleged_instruction
  BAD_TRAP;			! 04 fp_disabled
  TRAP(_window_overflow);	! 05 window_overflow
  TRAP(_window_underflow);	! 06 window_underflow
  BAD_TRAP;			! 07 memory_address_not_aligned
  TRAP(fptrap)			! 08 fp_exception
  SRMMU_DFAULT		! 09 data_access_exception (in mmu_asm.S)
  BAD_TRAP;			! 0A tag_overflow

  TRAP(_skipn);			! 0B watchpoint_exception
  BAD_TRAP;			! 0C undefined
  BAD_TRAP;			! 0D undefined
  BAD_TRAP;			! 0E undefined
  BAD_TRAP;			! 0F undefined
  BAD_TRAP;			! 10 undefined

  /* Interrupt entries */
  TRAP(_irqh);			! 11 interrupt level 1
/*  TRAP(_reex);			! 11 interrupt level 1 */
  TRAP(_irqh);			! 12 interrupt level 2
  TRAP(_irqh);			! 13 interrupt level 3
  TRAP(_irqh);			! 14 interrupt level 4
  TRAP(_irqh);			! 15 interrupt level 5
  TRAP(_irqh);			! 16 interrupt level 6
  TRAP(_irqh);			! 17 interrupt level 7
  TRAP(_irqh);			! 18 interrupt level 8
  TRAP(_irqh);			! 19 interrupt level 9
  TRAP(_irqh);			! 1A interrupt level 1
  TRAP(_irqh);			! 1B interrupt level 11
  TRAP(_irqh);			! 1C interrupt level 12
  TRAP(_irqh);			! 1D interrupt level 13
  TRAP(_irqh);			! 1E interrupt level 14
  TRAP(_irqh);			! 1F interrupt level 15
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 20 - 23 undefined
  BAD_TRAP;					! 24 cp_disabled
	    BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 25 - 27 undefined
  BAD_TRAP;					! 28 cp_exception
	    BAD_TRAP; BAD_TRAP; 		! 29 - 2A undefined
  TRAP(_reexn); 				! 2B data_store_error
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 2C - 2F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 30 - 33 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 34 - 37 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 38 - 3B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 3C - 3F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 40 - 43 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 44 - 47 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 48 - 4B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 4C - 4F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 50 - 53 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 54 - 57 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 58 - 5B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 5C - 5F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 60 - 63 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 64 - 67 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 68 - 6B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 6C - 6F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 70 - 73 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 74 - 77 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 78 - 7B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 7C - 7F undefined

  /* Software traps */
  SOFT_TRAP; SOFT_TRAP; TRAP(spil); 		! 80 - 82
  TRAP(_flush_windows)				! 83
  TRAP(_skip); SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 84 - 87
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 88 - 8B
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 8C - 8F
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 90 - 93
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 94 - 97
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 98 - 9B
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 9C - 9F
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! A0 - A3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! A4 - A7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! A8 - AB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! AC - AF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! B0 - B3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! B4 - B7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! B8 - BB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! BC - BF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! C0 - C3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! C4 - C7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! C8 - CB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! CC - CF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! D0 - D3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! D4 - D7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! D8 - DB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! DC - DF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! E0 - E3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! E4 - E7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! E8 - EB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! EC - EF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! F0 - F3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! F4 - F7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! F8 - FB 
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! FC - FF


!
_reset:

!	flush				! enable caches
!	set	PREGS, %g1
!	set	0x1000f, %g2
!	st	%g2, [%g1 + CCTRL]	! initialise registers
!	st	%g0, [%g1 + IOREG]
!	st	%g0, [%g1 + IOICONF]
!	st	%g0, [%g1 + IFORCE]
!	st	%g0, [%g1 + UCTRL0]
!	st	%g0, [%g1 + UCTRL1]
!	set	-1, %g2
!	st	%g0, [%g1 + ICLEAR]

	set	_text_start, %g1	
	mov	%g1, %tbr
!	set	2, %g2
!	mov	%g2, %wim

!	call	_initregs
!
	nop
!	mov	%g3, %sp	! stack pointer
	call leon_test		! call test routine
	nop

_irqh:
	! store trap type in irqtbl for later verification
	set	_irqtbl, %l4
	ldub	[%l4], %l5
	srl	%l3, 4, %l3
	and	%l3, 0x0ff, %l3
	stb	%l3, [%l4+%l5]
	add	%l5, 1, %l5
	stb	%l5, [%l4]
	jmpl	%l1, %g0
	rett	%l2 
	nop
	nop
_reex:
	jmpl	%l1, %g0
	rett	%l2 
	nop
	nop
fptrap:
	set	fsr1, %l4
	set	fq1, %l6
1:
	st	%fsr, [%l4]
	ld	[%l4], %l5
	srl	%l5, 13, %l5
	andcc	%l5, 1, %l5
	bne,a	1b
	std	%fq, [%l6]
	jmpl	%l2, %g0
	rett	%l2 + 4 
	nop
_skip:
	jmpl	%l2, %g0
	rett	%l2 + 4 
	nop
	nop

_skipn:
	set	_dexcn, %l4
	ld	[%l4], %l5
	subcc	%l5, 1, %l5
	st	%l5, [%l4]
	bl	dexcfail
	nop
	jmpl	%l2, %g0
	rett	%l2 + 4 
_reexn:
	set	_dexcn, %l4
	ld	[%l4], %l5
	subcc	%l5, 1, %l5
	st	%l5, [%l4]
	bl	dexcfail
	nop
	jmpl	%l1, %g0
	rett	%l2 
dexcfail:
	ta	0
	nop
	nop

halt:	ta	0
	
	
/* Number of register windows */
#define NWINDOWS 	8

  	 		!Window overflow trap handler.
  	.global _window_overflow

_window_overflow:

  	mov  %wim, %l3       		! Calculate next WIM
  	mov  %g1, %l7           
  	srl  %l3, 1, %g1        
  	sll  %l3, NWINDOWS-1 , %l4
  	or   %l4, %g1, %g1

  	save                              ! Get into window to be saved.
  	mov  %g1, %wim
  	nop; nop; nop
        st   %l0, [%sp + 0];
        st   %l1, [%sp + 4];
        st   %l2, [%sp + 8];
        st   %l3, [%sp + 12];
        st   %l4, [%sp + 16]; 
        st   %l5, [%sp + 20];
        st   %l6, [%sp + 24]; 
        st   %l7, [%sp + 28]; 
        st   %i0, [%sp + 32]; 
        st   %i1, [%sp + 36]; 
        st   %i2, [%sp + 40]; 
        st   %i3, [%sp + 44]; 
        st   %i4, [%sp + 48]; 
        st   %i5, [%sp + 52]; 
        st   %i6, [%sp + 56]; 
        st   %i7, [%sp + 60];
  	restore				! Go back to trap window.
  	mov  %l7, %g1
  	jmp  %l1			! Re-execute save.
  	rett %l2

  /* Window underflow trap handler.  */

  	.global  _window_underflow

_window_underflow:

	mov  %wim, %l3			! Calculate next WIM
	sll  %l3, 1, %l4
  	srl  %l3, NWINDOWS-1, %l5
  	or   %l5, %l4, %l5
  	mov  %l5, %wim
  	nop; nop; nop
  	restore				! Two restores to get into the
  	restore				! window to restore
        ld   [%sp + 0], %l0; 		! Restore window from the stack
        ld   [%sp + 4], %l1; 
        ld   [%sp + 8], %l2; 
        ld   [%sp + 12], %l3; 
        ld   [%sp + 16], %l4; 
        ld   [%sp + 20], %l5; 
        ld   [%sp + 24], %l6; 
        ld   [%sp + 28], %l7; 
        ld   [%sp + 32], %i0; 
        ld   [%sp + 36], %i1; 
        ld   [%sp + 40], %i2; 
        ld   [%sp + 44], %i3; 
        ld   [%sp + 48], %i4; 
        ld   [%sp + 52], %i5; 
        ld   [%sp + 56], %i6; 
        ld   [%sp + 60], %i7;
  	save				! Get back to the trap window.
  	save
  	jmp  %l1			! Re-execute restore.
  	rett  %l2

	.global	_flush_windows	
_flush_windows:		

	mov	%psr, %g1
	or	%g1, 0x0f00, %g2
	restore				! enter previous frame (cannot trap)
        wr      %g2, 0x20, %psr		! enable traps, disable interrupts
	nop; nop; nop
	save				! 6 save to flush all windows
	save
	save
	save
	save
	save
	restore				! 5 restore to enter trapped frame
	restore
	restore
	restore
	restore
	mov      %g1, %psr		! restore %psr
	nop; nop; nop
  	jmp  %l2			! Jump to nPC
  	rett  %l2 + 4

	.text
	.align 4
	.global _initregs
	.proc	04

_initregs:
	
	mov	%g0, %g1
	mov	%o7, %g2
!	mov	%g0, %g3
	mov	%g0, %g4
	mov	%g0, %g5
	mov	%g0, %g6
	mov	%g0, %g7
	mov	%wim, %g7
	mov	%g0, %wim
	nop; nop; nop
1:
	mov	%g0, %l0
	mov	%g0, %l1
	mov	%g0, %l2
	mov	%g0, %l3
	mov	%g0, %l4
	mov	%g0, %l5
	mov	%g0, %l6
	mov	%g0, %l7
	mov	%g0, %o0
	mov	%g0, %o1
	mov	%g0, %o2
	mov	%g0, %o3
	mov	%g0, %o4
	mov	%g0, %o5
	mov	%g0, %o6
	mov	%g0, %o7
	save
	subcc	%g1, 7, %g0
	bne	1b
	inc	%g1
	mov	%g7, %wim
	nop
	nop
	nop
	mov	%g2, %o7
	retl
	nop

	.global _setpil
_setpil:
	retl
	ta	2

spil:
	mov	%psr, %l4
	srl	%l4, 8, %l5
	andn	%l4, 0x0f00, %l4
	sll	%i0, 8, %i0
	and	%i0, 0x0f00, %i0
	or	%i0, %l4, %l4
	mov	%l4, %psr
	and	%l5, 0x0f, %i0
	jmpl	%l2, %g0
	rett	%l2 + 4 

hello:
.string	"Starting test"

	.data
	.global _dexcn, dexcn, _irqtbl, irqtbl
_dexcn:	
dexcn:	
	.word 0
_irqtbl: 
irqtbl: 
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
