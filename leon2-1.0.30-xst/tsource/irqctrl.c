#include "leon.h"
#include "test.h"

irq_test()
{
	extern volatile char irqtbl[];
	int i, a, psr;
	volatile int marr[4];
	volatile int larr[4];

	report(IRQ_TEST);	/* report test type */
	lr->uartctrl1 = 0x0;	/* clear uart1 ctrl */
	lr->uartctrl2 = 0x0;	/* clear uart2 ctrl */
	lr->irqmask = 0x0;	/* mask all interrupts */
	lr->irqclear = -1;	/* clear all pending interrupts */
	irqtbl[0] = 1;		/* init irqtable */

/* test that interrupts are properly prioritised */
	
	lr->irqforce = 0x0fffe;	/* force all interrupts */
	if (lr->irqforce != 0x0fffe) fail(1); /* check force reg */

	lr->irqmask = 0x0fffe;	  /* unmask all interrupts */
	if (lr->irqmask != 0x0fffe) fail(2); /* check mask reg */
	while (lr->irqforce) {};  /* wait until all iterrupts are taken */

	/* check that all interrupts were take in right order */
	if (irqtbl[0] != 16) fail(3);
	for (i=1;i<16;i++) { if (irqtbl[i] != (0x20 - i))  fail(4);}

/* test priority of the two interrupt levels */

	irqtbl[0] = 1;			/* init irqtable */
	lr->irqmask = 0xaaaafffe;	/* odd irq -> level 1 */
	if (lr->irqmask != 0xaaaafffe) fail(5); /* check mask reg */
	lr->irqforce = 0x0fffe;	/* force all interrupts */
	while (lr->irqforce) {};  /* wait until all iterrupts are taken */

	/* check that all interrupts were take in right order */
	if (irqtbl[0] != 16) fail(6);
	for (i=1;i<8;i++) { if (irqtbl[i] != (0x20 - (i*2-1)))
		fail(7);}
	for (i=2;i<8;i++) { if (irqtbl[i+8] != (0x20 - (i*2)))
		fail(8);}

/* check interrupts of multi-cycle instructions */

	marr[0] = 1; marr[1] = marr[0]+1; marr[2] = marr[1]+1; 
	a = marr[2]+1; marr[3] = a; larr[0] = 6;

	lr->irqmask = 0x0;	/* mask all interrupts */
	irqtbl[0] = 1;		/* init irqtable */
	lr->irqmask = 0x00002;	  /* unmask interrupt */
	if (lr->leonconf & 0x100) { /* check for HW mul */
		lr->irqforce = 0x00002;	/* force interrupt */
		asm("
		nop; 
		umul %g0, %g1, %g0
		umul %g0, %g1, %g0
		umul %g0, %g1, %g0
		");
	}
	lr->irqforce = 0x00002;	/* force interrupt */
	asm("nop;");
	larr[1] = larr[0];
	if (larr[0] != 6) fail(10);
	lr->irqforce = 0x00002;	/* force interrupt */
	asm("nop;");
	larr[1] = 0;
	if (larr[1] != 0) fail(11);

	while (lr->irqforce) {};  /* wait until all iterrupts are taken */

	/* check number of interrupts */
	if (lr->leonconf & 0x100) { if (irqtbl[0] != 4) fail(13);}
	else if (irqtbl[0] != 3) {fail(13);}

	lr->irqmask = 0x0;	/* mask all interrupts */

/* check that PSR.PIL work properly */

	lr->irqforce = 0x0fffe;	/* force all interrupts */
	irqtbl[0] = 1;		/* init irqtable */
	psr = getpsr() | (15 << 8);
	setpsr(psr); /* PIL = 15 */
	lr->irqmask = -1;	/* enable all interrupts */
	while (!lr->irqmask);   /* avoid compiler optimisation */
	if (irqtbl[0] != 2) fail(14);
	if (irqtbl[1] != 0x1f) fail(15);
	setpsr(getpsr() - (1 << 8));
	for (i=2;i<16;i++) { 
		setpsr(getpsr() - (1 << 8));
		if (irqtbl[0] != i+1) fail(14);
		if (irqtbl[i] != (0x20 - i))  fail(15);
	}

/* test optional secondary interrupt controller */
/*
	lr->irqmask = 0x0;
	lr->imask2 = 0x0;
	lr->ipend2 = 0x0;	
	lr->ipend2 = 0x1;
	if (!lr->ipend2) return;
	lr->ipend2 = -1;
	lr->imask2 = -1;
	for (i=lr->istat2 & 0x1f; i >=0; i--) {
		if ((lr->istat2 & 0x1f) != i) fail (17+i);
		lr->istat2 = (1 << i);
	        lr->irqclear = -1;
	}
	if (lr->istat2 & 0x20) fail (33);
	if (lr->irqpend) fail (34);
*/

}
	
