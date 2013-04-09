
/*
 *	@(#)traptable.s	109.1 4/18/90	Mizar, Inc. & Sun Microsystems, Inc.
 */

/*
 *	Copyright (c) 1989 Mizar, Inc
 *	Copyright (c) 1989 Sun Microsystems, Inc.
 *	All Rights Reserved.
 *
 *	Please see copyright.h for complete information.
 */

#define ASMLANGUAGE
#define	REG_SAVE_SIZE		(504)
#define	g_target		(0x200250c)
#define	g_lofault		(0x2002510)
#define	gp_reg_save		(0x2002240)
#define	g_fpu_exists		(0x200253c)
#define	RS_FPCTX		(96)
#define	FPCTX_REGS		(0)
#define	FPCTX_FSR		(128)
#define	FPCTX_Q		(136)
#define	FPCTX_QCNT		(264)
#define	FPCTX_EN		(265)
#define	LF_FHANDLER		(32)

/*
 *	@(#)mon_reset.h	109.1 4/18/90	Mizar, Inc. & Sun Microsystems, Inc.
 */

/*
 *	Copyright (c) 1989 Mizar, Inc
 *	Copyright (c) 1989 Sun Microsystems, Inc.
 *	All Rights Reserved.
 *
 *	Please see copyright.h for complete information.
 */

#ifdef ASMLANGUAGE
	.global	_hardreset
#else  /*!ASMLANGUAGE*/
	extern void	hardreset();
	extern void	warm_restart();
#endif /*ASMLANGUAGE*/

/*
 *	@(#)traptypes.h	109.1 4/18/90	Mizar, Inc. & Sun Microsystems, Inc.
 */


/*
 *	Copyright (c) 1989 Mizar, Inc
 *	Copyright (c) 1989 Sun Microsystems, Inc.
 *	All Rights Reserved.
 *
 *	Please see copyright.h for complete information.
 */

#if !defined(ASMLANGUAGE)

   /*
    * The TrapType type is used for encoding a trap type.
    */
   typedef unsigned int	TrapType;

   /*
    * trapstrings contains the names of the traps; used by print_trap()
    */
   extern char *trapstrings[];

   /*
    * print_trap prints an ascii message telling what the trap type is
    */
   extern void print_trap();
#endif ASMLANGUAGE

/*
 * Trap type values.
 */
#define TT(X)			((X)<<4)

#define RAW_TRAP_MASK		0xFF

/*
 * The Coprocessor bit.
 */
#define CP_BIT 0x20

/*
 * Hardware traps.
 */
#define T_RESET			0x00
#define T_INSTR_ACC_EXC		0x01
#define T_UNIMP_INSTR		0x02
#define T_PRIV_INSTR		0x03
#define T_FP_DISABLED		0x04
#define T_CP_DISABLED		(0x4 | CP_BIT)
#define T_WIN_OVERFLOW		0x05
#define T_WIN_UNDERFLOW		0x06
#define T_ALIGNMENT		0x07
#define T_FP_EXCEPTION		0x08
#define T_CP_EXCEPTION		(0x8 | CP_BIT)
#define T_DATA_ACC_EXC		0x09
#define T_TAG_OVERFLOW		0x0A
#define	T_INT			0x10
#define	T_INT_LEVEL		0x0F
#define T_INT_LEVEL_1		0x11
#define T_INT_LEVEL_2		0x12
#define T_INT_LEVEL_3		0x13
#define T_INT_LEVEL_4		0x14
#define T_INT_LEVEL_5		0x15
#define T_INT_LEVEL_6		0x16
#define T_INT_LEVEL_7		0x17
#define T_INT_LEVEL_8		0x18
#define T_INT_LEVEL_9		0x19
#define T_INT_LEVEL_10		0x1A
#define T_INT_LEVEL_11		0x1B
#define T_INT_LEVEL_12		0x1C
#define T_INT_LEVEL_13		0x1D
#define T_INT_LEVEL_14		0x1E
#define T_INT_LEVEL_15		0x1F
#define T_R_REG_ACCESS_ERR	0x20
#define T_INSTR_ACC_ERR		0x21
#define T_DATA_ACC_ERR		0x29
#define T_DIV_BY_ZERO		0x2A
#define T_DATA_STORE		0x2B

/*
 * Software traps (ticc instructions)
 */
#define ST_MONSVC		0x00
#define ST_RDB_BKPT		0x01
#define ST_FLUSH_WINDOWS	0x03
#define ST_MON_BKPT		0x7B

/*
 * Software trap type values.
 */
#define T_SOFTWARE_TRAP		0x80
#define T_MONSVC		(T_SOFTWARE_TRAP + ST_MONSVC)
#define T_RDB_BKPT		(T_SOFTWARE_TRAP + ST_RDB_BKPT)
#define T_FLUSH_WINDOWS		(T_SOFTWARE_TRAP + ST_FLUSH_WINDOWS)
#define T_MON_BKPT		(T_SOFTWARE_TRAP + ST_MON_BKPT)
#define T_ESOFTWARE_TRAP	0xFF

/*
 * Pseudo traps.
 */
#define T_ZERO			0x00

/* pseudo traps - bits 8-11 only! */
#define T_INVALID		0x100
#define T_TARGET		0x200

#ifdef UNDEF	/* following #defines are not currently in use */

/*
 * Software traps (ticc instructions).
 */
#define ST_SYSCALL		0x00
#define ST_RDB_BKPT		0x01
#define ST_DIV0			0x02
#define ST_FLUSH_WINDOWS	0x03
#define ST_CLEAN_WINDOWS	0x04
#define ST_RANGE_CHECK		0x05
#define ST_FIX_ALIGN		0x06
#define ST_INT_OVERFLOW		0x07

#define ST_GETCC		0x20
#define ST_SETCC		0x21

#define ST_MON_BKPT		0x7B

/*
 * Software trap vectors 16 - 31 are reserved for use by the user
 * and will not be usurped by Sun.
 */

/*
 * Software trap type values.
 */
#define T_SOFTWARE_TRAP		0x80
#define T_ESOFTWARE_TRAP	0xFF
#define T_SYSCALL		(T_SOFTWARE_TRAP + ST_SYSCALL)
#define T_RDB_BKPT		(T_SOFTWARE_TRAP + ST_RDB_BKPT)
#define T_DIV0			(T_SOFTWARE_TRAP + ST_DIV0)
#define T_FLUSH_WINDOWS		(T_SOFTWARE_TRAP + ST_FLUSH_WINDOWS)
#define T_CLEAN_WINDOWS		(T_SOFTWARE_TRAP + ST_CLEAN_WINDOWS)
#define T_RANGE_CHECK		(T_SOFTWARE_TRAP + ST_RANGE_CHECK)
#define T_FIX_ALIGN		(T_SOFTWARE_TRAP + ST_FIX_ALIGN)
#define T_INT_OVERFLOW		(T_SOFTWARE_TRAP + ST_INT_OVERFLOW)

#define T_GETCC			(T_SOFTWARE_TRAP + ST_GETCC)
#define T_SETCC			(T_SOFTWARE_TRAP + ST_SETCC)

#define T_MON_BKPT		(T_SOFTWARE_TRAP + ST_MON_BKPT)

/*
 * Programmer defined traps.
 */
#define WATCHDOG_TRAP                    (256)
#define BOOT_TRAP                        (257)
#define EXIT_TO_MONITOR_TRAP             (258)
#define SOFT_RESET_TRAP                  (259)
#define ABORT_TRAP                       (260)
#define EXTENDED_TESTS_TRAP              (261)
#define BOOT_EXEC_TRAP                   (262)
#define MEMORY_ERROR_TRAP                (263)
#define BUS_ERROR_TRAP                   (264)
#define UNKNOWN_TRAP                     (500)


#endif UNDEF



/*
 * TRAP TABLE macros.
 *
 * The following macros are TRAP TABLE entries.  Each 16-byte entry consists
 * of four instructions which jump to an appropriate trap handler after saving
 * the value of the PSR in %l0.
 */

/*
 * TRAP TABLE entry for traps which jump
 * to a programmer-specified trap handler.
 */
#define TRAP(H)  mov %psr, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); nop;

/* 
 * General purpose TRAP TABLE entry for all traps 
 * which use the common trap handler entry point "trap_entry".
 */
#define MON_TRAP(PT) \
    rd %psr, %l0; sethi %hi(_halt),%l4; jmp %l4+%lo(_halt); \
		or %g0, (((.-_trap_table) >> 4) | (PT & 0xf00)), %l5;
		
#define IRQ_TRAP(LVL) \
    rd %psr, %l0; sethi %hi(irq_trap),%l4; jmp %l4+%lo(irq_trap); \
                or %g0, (((.-_trap_table) >> 4) | (LVL & 0xf00)), %l5;


#define BAD_TRAP MON_TRAP(T_INVALID);
  /*
   * The TRAP TABLE.
   *
   * This must be the first code in the boot prom.   When a RESET trap is taken,
   * the PC is set to "0" and the nPC is set to "4" (i.e. we are in BOOT state).
   * When a NON-RESET trap is taken, the PC is set to "TBR(TBA)+(TBR(TT)*16)" 
   * and the nPC is set to "TBR(TBA)+(TBR(TT)*16)+4" (i.e. we vector to 
   * TBR(TBA)+(TBR(TT)*16)).  Upon entry to a trap handler, the following events
   * will have taken place.
   *      1) Traps have been disabled.
   *      2) TBR(TT) has been set to the appropriate trap type.
   *      3) Previous state of PSR(S) has been copied into PSR(PS).
   *      4) PSR(S) field has been set (i.e. We are now in supervisor mode.).
   *      5) CWP has been decremented modulo the number of Windows 
   *         (CWP = (CWP-1) % number_of_windows).
   *      6) Previous PC and nPC have been written into %l1 and %l2 of the new
   *         window, respectively.
   *      7) PC and nPC have been set as described above.
   *
   * Registers:
   *      %l0 = %psr immediately after trap
   *      %l1 = trapped PC
   *      %l2 = trapped nPC
   *      %l3 = trap type code -- ((TT/16) | psuedo-trap bits)
   */
  .seg    "text"
  .global _trap_table, start, _main
start:
_main:
_trap_table:
  TRAP(_hardreset);		! 00 reset trap 
  TRAP(_illint);			! 01 instruction_access_exception
  TRAP(_illint);			! 02 illegal_instruction
  TRAP(_illint);			! 03 priveleged_instruction
  TRAP(_illint);			! 04 fp_disabled
  TRAP(_illint);	! 05 window_overflow
  TRAP(_illint);	! 06 window_underflow
  TRAP(_illint);			! 07 memory_address_not_aligned
  TRAP(_illint);			! 08 fp_exception
  TRAP(_skip);			! 09 data_access_exception
  TRAP(_illint);			! 0A tag_overflow
  /* 
   * The next trap levels from 0B to 0x10 are not 
   * defined (i.e. they should not be generated).
   */
  BAD_TRAP;			! 0B undefined
  BAD_TRAP;			! 0C undefined
  BAD_TRAP;			! 0D undefined
  BAD_TRAP;			! 0E undefined
  BAD_TRAP;			! 0F undefined
  BAD_TRAP;			! 10 undefined
  /*
   * The following are interrupts.
   */
  TRAP(_halt);			! 11 interrupt level 1,  masked HW errors
  TRAP(mecext0);		! 12 interrupt level 2,  external irq 0
  TRAP(mecext1);		! 13 interrupt level 3,  external irq 1
  TRAP(0);			! 14 interrupt level 4,  UART A
  TRAP(0);			! 15 interrupt level 5,  UART B
  TRAP(corr_trap);		! 16 interrupt level 6,  correctable EDAC error
  TRAP(0);			! 17 interrupt level 7,  UART error
  TRAP(corr_trap);		! 18 interrupt level 8,  DMA access error
  TRAP(0);			! 19 interrupt level 9,  DMA time-out
  TRAP(0);			! 1A interrupt level 10, external irq 2
  TRAP(0);			! 1B interrupt level 11, external irq 3
  TRAP(0);			! 1C interrupt level 12, GP timer
  TRAP(0);			! 1D interrupt level 13, RT clock
  TRAP(0);			! 1E interrupt level 14, external irq 4
  TRAP(_halt);		! 1F interrupt level 15, watch-dog
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 20 - 23 undefined
  MON_TRAP(0);					! 24 cp_disabled
	    BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 25 - 27 undefined
  MON_TRAP(0);					! 28 cp_exception
	    BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 29 - 2B undefined
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
  /*
   * Define all 128 programmer-initiated traps.
   */
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 80 - 83
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 84 - 87
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 88 - 8B
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 8C - 8F
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 90 - 93
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 94 - 97
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 98 - 9B
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! 9C - 9F
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! A0 - A3
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! A4 - A7
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! A8 - AB
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! AC - AF
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! B0 - B3
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! B4 - B7
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! B8 - BB
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! BC - BF
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! C0 - C3
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! C4 - C7
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! C8 - CB
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! CC - CF
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! D0 - D3
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! D4 - D7
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! D8 - DB
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! DC - DF
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! E0 - E3
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! E4 - E7
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! E8 - EB
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! EC - EF
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! F0 - F3
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! F4 - F7
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! F8 - FB 
  MON_TRAP(0); MON_TRAP(0); MON_TRAP(0); MON_TRAP(0);	! FC - FF


	.global	_hardreset

#define ASMLANGUAGE
#ifndef _PSL_
#define _PSL_

/*
 * Definition of bits in the Sun-4 PSR (Processor Status Register)
 *  ________________________________________________________________________
 * | IMPL | VER |      ICC      | resvd | EC | EF | PIL | S | PS | ET | CWP |
 * |      |     | N | Z | V | C |       |    |    |     |   |    |    |     |
 * |------|-----|---|---|---|---|-------|----|----|-----|---|----|----|-----|
 *  31  28 27 24  23  22  21  20 19   14  13   12  11  8   7   6    5  4   0
 *
 * Reserved bits are defined to be initialized to zero and must
 * be preserved if written, for compatabily with future revisions.
 */

#define PSR_CWP		0x0000001F	/* current window pointer */
#define PSR_ET		0x00000020	/* enable traps */
#define PSR_PS		0x00000040	/* previous supervisor mode */
#define PSR_S		0x00000080	/* supervisor mode */
#define PSR_PIL		0x00000F00	/* processor interrupt level */
#define PSR_EF		0x00001000	/* enable floating point unit */
#define PSR_EC		0x00002000	/* enable coprocessor */
#define PSR_RSV		0x000FC000	/* reserved */
#define PSR_ICC		0x00F00000	/* integer condition codes */
#define PSR_C		0x00100000	/* carry bit */
#define PSR_V		0x00200000	/* overflow bit */
#define PSR_Z		0x00400000	/* zero bit */
#define PSR_N		0x00800000	/* negative bit */
#define PSR_VER		0x0F000000	/* mask version */
#define PSR_IMPL	0xF0000000	/* implementation */

#define PSL_ALLCC	PSR_ICC		/* for portability */
#define SR_SMODE	PSR_PS

/*
 * Handy psr values.
 */
#define PSL_USER	(PSR_S)		/* initial user psr */
#define PSL_USERMASK	(PSR_ICC)	/* user variable psr bits */

/*
 * Macros to decode psr.
 */
#define USERMODE(ps)	(((ps) & PSR_PS) == 0)
#define BASEPRI(ps)	(((ps) & PSR_PIL) == 0)

/*
 * Convert system interupt priorities (0-7) into a psr for splx.
 * In general, the processor priority (0-15) should be 2 times
 * the system priority.
 */
#define pritospl(n)	((n) << 9)

#define TBR_TT		0x00000FF0

#endif _PSL_
#define MON_PSR_INIT	( PSR_S | PSR_PS | PSR_EF | PSR_ET)
#define MON_TBR_INIT	(0x00000000 | 0x00000000)
#define	MON_WIM_INIT	2
/* #define	MON_WIM_INIT	(1 << (((MON_PSR_INIT & PSR_CWP) - 1) % 7)) */

