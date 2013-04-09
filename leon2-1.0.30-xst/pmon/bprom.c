/**************************************************************************/
/*                                                                        */
/*  Boot loader that atomatically detects attached ram and programs	  */
/*  memory configuration register 2 accordingly. Also contains an         */
/*  s-record loader. Fits in 1024 bytes.                                  */
/*  Copyright Jiri Gaisler, ESA/ESTEC, 2000.                              */
/*                                                                        */
/**************************************************************************/

/* Compile with LECCS:

   sparc-rtems-gcc -nostdlib -nostdinc -O2 -Ttext=0 bprom.c -o bprom

*/

/**********************************************************************/

/* LEON register layout */
struct lregs {
	volatile unsigned int memcfg1;		/* 0x00 */
	volatile unsigned int memcfg2;
	volatile unsigned int ectrl;
	volatile unsigned int failaddr;
	volatile unsigned int memstatus;		/* 0x10 */
	volatile unsigned int cachectrl;
	volatile unsigned int powerdown;
	volatile unsigned int writeprot1;
	volatile unsigned int writeprot2;	/* 0x20 */
	volatile unsigned int leonconf;
	volatile unsigned int dummy2;
	volatile unsigned int dummy3;
	volatile unsigned int dummy4;		/* 0x30 */
	volatile unsigned int dummy5;
	volatile unsigned int dummy6;
	volatile unsigned int dummy7;
	volatile unsigned int timercnt1;		/* 0x40 */
	volatile unsigned int timerload1;
	volatile unsigned int timerctrl1;
	volatile unsigned int wdog;
	volatile unsigned int timercnt2;
	volatile unsigned int timerload2;
	volatile unsigned int timerctrl2;
	volatile unsigned int dummy8;
	volatile unsigned int scalercnt;
	volatile unsigned int scalerload;
	volatile unsigned int dummy9;
	volatile unsigned int dummy10;
	volatile unsigned int uartdata1;
	volatile unsigned int uartstatus1;
	volatile unsigned int uartctrl1;
	volatile unsigned int uartscaler1;
	volatile unsigned int uartdata2;
	volatile unsigned int uartstatus2;
	volatile unsigned int uartctrl2;
	volatile unsigned int uartscaler2;
	volatile unsigned int irqmask;
	volatile unsigned int irqpend;
	volatile unsigned int irqforce;
	volatile unsigned int irqclear;
	volatile unsigned int piodata;
	volatile unsigned int piodir;
	volatile unsigned int pioirq;
};

/* boot assembly code, setup %wim, %psr and stack */
/* NOTE: no window handling, maximum function call-depth is 7 !! */

asm("
  
  .global _start, start

start:
_start:
        wr      %g0, 0xe0, %psr		! enable traps
	wr      %g0, 2, %wim       
	flush
	set	0x1000f, %g1
	set	0x80000000, %o0		! register base
	sub	%o0, 16, %g4		! top of ram
	st	%g1, [%o0 + 0x14]	! enable cache
	ld	[%o0 + 0x24], %o1	! probe for FPU
	and	%o1, 0x10, %o1
	sll	%o1, 8, %o1
        wr      %o1, 0xe0, %psr		 

	set	0xaa00, %o1		! enable both uarts
	st	%o1, [%o0 + 0xA4]	
	st	%g0, [%o0 + 0x74]	
	st	%g0, [%o0 + 0x84]	
	set	3, %o1
	st	%o1, [%o0 + 0x78]	
	st	%o1, [%o0 + 0x88]	
	
	set	-1, %o1			! start timer 1
	st	%o1, [%o0 + 0x44]	
	set	7, %o1
	st	%o1, [%o0 + 0x48]	

	set	0x40000000, %o1		! memory base
	ld	[%o0 + 4], %o2
	and	%o2, 0x0f, %o2
	set	0x1e20, %o3		! check for 32-bit memory
	or 	%o3, %o2, %o2
	st	%o2, [%o0 + 4]
	set	0x01234567, %o3
	st	%o3, [%o1]
	st	%g0, [%o1+4]
	lda	[%o1] 0, %o4
	subcc	%o3, %o4, %g0
	be	1f
	st	%g0, [%o1]
	sub	%o2, 0x10, %o2		! check for 16-bit memory
	st	%o2, [%o0 + 4]
	st	%o3, [%o1]
	st	%g0, [%o1+4]
	lda	[%o1] 0, %o4
	subcc	%o3, %o4, %g0
	be	1f
	nop
	sub	%o2, 0x10, %o2
	ba	2f
	st	%o2, [%o0 + 4]
1:
	st	%o3, [%o1]
	stb	%g0, [%o1+3]		! check for if read-mod-write is needed
	lda	[%o1] 0, %o4
	subcc	%o3, %o4, %g0
	bne	2f
	nop
	or 	%o2, 0x40, %o2
	st	%o2, [%o0 + 4]
2:

	set	0x10000000, %g2
1:
	st	%o3, [%g4]		! look for ram banks
	st	%g0, [%g4-4]
	lda	[%g4] 0, %o5
	subcc	%o5, %o3, %g0
	bne,a  	1b
	subcc	%g4, %g2, %g4

	srl	%g4, 28, %g5
	sub	%g5, 4, %g5

	add	%g2, %o1, %o1 		! determine size of ram banks
	sub	%o1, 16, %o1
	st	%o3, [%o1]		
1:
	srl	%g2, 1, %g2
	sub	%o2, 0x200, %o2
	st	%o2, [%o0 + 4]
	sub	%o1, %g2, %o1
	lda	[%o1] 0, %o5
	subcc	%o5, %o3, %g0
	be	1b
	nop
	add	%o2, 0x200, %o2
	st	%o2, [%o0 + 4]

1:

	set	0x40000000, %g4
	add	%o1, %g2, %o1		! set stack pointer
	andn	%o1, %g4, %o1
	sll	%o1, %g5, %o1
	or  	%o1, %g4, %sp

	sll	%g5, 1, %o3
	call	puts
	or 	%g0, bmsg1, %o0
	or	%g0, banknum, %o1
	call	puts
	add	%o3, %o1, %o0
	or	%g0, memsz, %o1
	srl	%o2, 6, %g5
	sub	%g5, 32, %g5
	andn	%g5, 1, %g5
	call	puts
	add	%o1, %g5, %o0
	or	%g0, memwidth, %o1
	srl	%o2, 2, %g5
	and	%g5, 0xc, %g5
	call	puts
	add	%o1, %g5, %o0
	call	puts
	or 	%g0, bmsg2, %o0

	andcc   %o2, 0x40, %g0
	be	1f
	nop
	call	puts
	or 	%g0, bmsg3, %o0

1:
	call	puts
	or 	%g0, bmsg4, %o0

	call	boot
	nop

	");

const char memwidth[3][4] = {" 8-", "16-", "32-"};
const char memsz[6][8] = {"*128K ", "*256K ", "*512K ", "*1024K ", "*2048K ", "*4096K "};
const char banknum[4][2] = {"1", "2", "3", "4"};
const char bmsg1[1][9] = {"LEON-1: "};
const char bmsg2[1][11] = {"bit memory"};
const char bmsg3[1][6] = {", rmw"};
const char bmsg4[1][6] = {"\n\n\r> "};

puts(unsigned char *s) {
	struct lregs *regs = (struct lregs *) 0x80000000;

	while(*s) {
		while (!(regs->uartstatus1 & 0x4));
		regs->uartdata1 = *s++;
	}
}
	
static inline gets(unsigned char *s) {
	struct lregs *regs = (struct lregs *) 0x80000000;
	do {
		while (!(regs->uartstatus1 & 0x1));
		*s = regs->uartdata1;
		if ((*s == '\r') || (*s == '\n')) {
			break;
		}
		s++;
	} while (1);
}
	
static
unsigned int h2i(int len, unsigned char *h)
{
	unsigned int tmp = 0;
	unsigned int i;
	unsigned char c;

	for (i=0; i<len; i++) {
	    c = h[i];
	    if (c >= 'A') c = c - 'A' + 10; else c -= '0';
	    tmp = (tmp << 4) | c;
	}
	return(tmp);
}

boot() {
	unsigned char r[256];
	int i, size, addr;
	char *data;
        void (*prog) ();
	double dummy;
  
	do {
	    gets(r);
	    if (r[0] == 'S') {
		addr = h2i(8, &r[4]);
		data = (unsigned char *) &r[12];
		if (r[1] == '3') {
	  	    size = (h2i(2, &r[2])*2 - 10) >> 1;
	  	    for (i=0;i<size;i++) ((char *)addr)[i] = h2i(2,&data[2*i]);
		} else if (r[1] == '7') {
	  	    prog = (void *) addr;
	  	    prog();
		}
	    }
	} while (1);
}
