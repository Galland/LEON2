/***************************************************************/
/*                                                             */
/*  Simple S-record loader to be used in LEON boot prom.       */
/*  Copyright Jiri Gaisler, ESA/ESTEC, 2000.                   */
/*                                                             */
/***************************************************************/

/* Compile with:

   sparc-rtems-gcc -nostdlib -nostdinc -O2 -Ttext 0 eprom.c -o eprom

*/

/**********************************************************************/
/* Board specific parameters - MAKE SURE THESE REFLECT YOUR HARDWARE! */

/* CPU frequency (Hz) */
#define CPU_FREQ  24576000

/* desired uart baud rate */
#define BAUD_RATE 38400

/* memory size of each ram bank (bytes) */
#define RAM_BANK_SIZE 0x200000

/* number of memory banks */
#define RAM_BANKS 2

/* init value for memory configuration register 1 */
#define MEMCFG1_VAL     0x3022

/* init value for memory configuration register 1 */
/* DEPENDS ON RAM_BANK_SIZE!!! */
#define MEMCFG2_VAL 0x1035               

/**********************************************************************/

/* AUTOMATICALLY GENERATED */

/* init value for timer pre-scaler, generates 1 MHz tick */
#define TIMER_SCALER_VAL (CPU_FREQ/1000000 -1)

/* init value for uart pre-scaler */
#define UART_SCALER_VAL  ((((CPU_FREQ*10) / (8 * BAUD_RATE))-5)/10)

/* stack pointer for boot application */
#define STACK_INIT      0x40000000 + ((RAM_BANK_SIZE * RAM_BANKS) - 16)     

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
  
  .global _start, start, stack_top

start:
_start:
        set     2, %g1
	mov     %g1, %wim       
        set     0x10c0, %g1
        wr      %g1, 0x20, %psr		! enable traps
        nop; nop; nop;
	set	stack_top, %g1
	ld	[%g1], %sp
	set	0x80000000, %g1
	ld	[%g1 + 0x14], %g1

	call	main
	sub	%sp, 0x40, %sp
	ta 	0			! Halt if _main would return ...

	");

puts(unsigned char *s) {
	struct lregs *regs = (struct lregs *) 0x80000000;

	while(*s) {
		while (!(regs->uartstatus1 & 0x4));
		regs->uartdata1 = *s++;
	}
}
	
gets(unsigned char *s) {
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
	
typedef struct {
	unsigned int addr;
	unsigned int size;
	unsigned int type;
	unsigned char *data;
	unsigned char *mem;
} recbuf;

static
unsigned int h2i(int len, unsigned char *h)
{
	int tmp = 0;
	int i;
	unsigned char c;

	for (i=0; i<len; i++) {
	    c = h[i];
	    if (c >= 'A') c = c - 'A' + 10; else c -= '0';
	    tmp = (tmp << 4) | c;
	}
	return(tmp);
}

void decode_srec(unsigned char *r, recbuf *rb)
{
	int alen;

	rb->type = 3; alen = 0;
	if ((r[1] > '0') && (r[1] < '4')){
	  alen = 2*(h2i(1,&r[1]) + 1);
	  rb->type = 1;
	} else if ((r[1] >= '7') && (r[1] <= '9')){
	  alen = 2*(11 - h2i(1,&r[1]));
	  rb->type = 2;
	} else if (r[1] == '0'){
	  alen = 4;
	  rb->type = 0;
	}
	rb->addr = h2i(alen, &r[4]);
	rb->size = h2i(2, &r[2])*2 - alen - 2;
	rb->data = (unsigned char *) &r[4 + alen];
}

void extract_srec(recbuf *rb)
{
    int i;
    unsigned char d;
    void (*prog) ();

    switch (rb->type) {
    case 0:
	break;
    case 1:
	for (i=0;i<(rb->size/2);i++) {
		d = h2i(2,&rb->data[2*i]);
		((char *)rb->addr)[i] = d;
	}
        break;
    case 2:
	prog = (void *) rb->addr;
        puts("starting program: \n");
	prog();
	break;
    default:
    }
}

main() {
	struct lregs *regs = (struct lregs *) 0x80000000;
	volatile int *ram = (int *) 0x40000000;
	unsigned char buf[256];
	recbuf srec;
	_init();
	puts("LEON S-Record loader\n\n\r> ");
	do {
		gets(buf);
		switch (buf[0]) {
		case 'S': 
		case 's': 
			decode_srec(buf, &srec);
			extract_srec(&srec);
			break;
		}
	} while (1);
}

const int stack_top = STACK_INIT;

_init()
{
	struct lregs *regs = (struct lregs *) 0x80000000;

	/* Don't flush cache in case we are booting from it ! */
	if (!(regs->cachectrl & 3)) {
		asm("flush");
		regs->cachectrl  = 0x1000f;
	}
	regs->piodir      = 0xaa00;	/* enable UART I/O ports */
	regs->irqmask     = 0;
	regs->irqpend     = 0;
	regs->irqforce    = 0;
	regs->memcfg1     = MEMCFG1_VAL;
	regs->memcfg2     = MEMCFG2_VAL;
	regs->scalercnt   = TIMER_SCALER_VAL;
	regs->scalerload  = TIMER_SCALER_VAL;
	regs->timerload1  = -1;
	regs->timerctrl1  = 7;
	regs->uartscaler1 = UART_SCALER_VAL;
	regs->uartscaler2 = UART_SCALER_VAL;
	regs->uartstatus1 = 0;
	regs->uartstatus2 = 0;
	regs->uartctrl1   = 3;
	regs->uartctrl2   = 3;
}


asm(".align 16");
