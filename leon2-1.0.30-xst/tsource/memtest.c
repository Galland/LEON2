#include "leon.h"
#include "test.h"

extern volatile int dexcn;
volatile int stest;
volatile int dtest;
volatile int xtest;
volatile long long ytest, ddtmp;
volatile int xarr[2];
volatile char *ztest;
volatile int *yptr;

dblerr(int *p)
{
	asm("
	set	0x80000000, %o1
	ld	[%o1 + 0x08], %o4
	or 	%o4, 0x400, %o3
	st	%o3, [%o1 + 0x08]
	ld	[%o0], %o2
	ld	[%o1 + 0x08], %o3
	xor	%o2, 3, %o2
	andn	%o3, 0x400, %o3
	or 	%o3, 0x800, %o3
	st	%o3, [%o1 + 0x08]
	st	%o2, [%o0]
	st	%o4, [%o1 + 0x08]
	");
}

asm(".align 32");
dumfunc()
{
	asm("nop; nop; nop;");
}

int
edac_test()
{
	int tmp,i;


	/* skip test if edac disabled */
	if (!((lr->ectrl >> REDAC_CONF_BIT) & 1))
		return(0);	

	report(EDAC_TEST);
	dexcn = 0;
	lr->memstatus = 0;			/* initialise MSTAT */
	lr->cachectrl &= ~0x0c;		/* disable data cache */

	/* test single-bit errors in all positions */

	stest = dtest = xtest = 0; 
	dblerr((int *) &dtest); dblerr((int *) &xtest);
	lr->ectrl |= 0x80c; tmp = stest; stest = 1;

	if ((stest != 0) || (lr->failaddr != (int) &stest) ||
	   (lr->memstatus != 0x382))
	{
		fail(1);
	}

	for (i=1;i<32;i++) { 
		stest = 1 << i; 
		if (stest != 0) break;
	}
	if ((i!=32) || (lr->failaddr != (int) &stest) || 
		(lr->memstatus != 0x382))
	{
		fail(2);
	}

	/* insert single-error in instructions */
	lr->ectrl &= ~0x0ff; lr->ectrl |= 0x06e;
	tmp = *((int *) dumfunc); *((int *) dumfunc) = tmp ^ 1;
	lr->ectrl &= ~0x0ff; lr->ectrl |= 0x00c;
	
	/* check that FAR is not loaded on second error */

	lr->ectrl &= ~0x800; dexcn = 1; tmp = dtest;
	if ((lr->failaddr != (int) &stest) || (lr->memstatus != 0x382) ||
		(dexcn != 0)) { fail(3); }

	/* clear memory status register and provoke double error */
	lr->memstatus = 0; dexcn = 1; tmp = xtest;
	if ((lr->failaddr != (int) &xtest) || (lr->memstatus != 0x182) ||
		(dexcn != 0)) fail(4);

	/* check that FAR is not changed */
	dexcn = 1; tmp = dtest;
	if ((lr->failaddr != (int) &xtest) || (lr->memstatus != 0x182) ||
		(dexcn != 0)) fail(5);

	/* check errors during byte write */
	ztest = (char *) &dtest; dexcn = 1;
	lr->memstatus = 0; ztest[0] = 4;
	if ((lr->failaddr != (int) &dtest) || (lr->memstatus != 0x100) ||
		((lr->irqpend & 2) == 0)) { fail(6); }
	lr->irqclear = 2;
	lr->ectrl &= ~(1 << REDAC_CONF_BIT);	/* disable edac */
	if (dtest != 3) fail(7);/* check that write cycle was aborted */
	lr->ectrl |= (1 << REDAC_CONF_BIT);	/* enable edac */

	ztest = (char *) &stest;
	stest = 0; lr->failaddr = 0;
	lr->ectrl |= 0x800; stest = 1^stest; lr->ectrl &= ~0x800;
	lr->memstatus = 0;  ((char *) &stest)[2] = 5;
	if ((stest!=0x500) || ((lr->failaddr ^ ((int) &(stest))) & ~3) || 
		(lr->memstatus != 0x300))
		fail(8);

	/* check load/store double exceptions */
	ytest = 0; lr->failaddr = 0; yptr = (int *) &ytest; dblerr((int *)yptr);
	lr->memstatus = 0; dexcn = 1; ddtmp = 0;
	ddtmp = ytest;	/* read exception on first word */
	if ((lr->failaddr != (int) &ytest) || (lr->memstatus != 0x182))
		fail(9);

	ytest = 0; lr->failaddr = 0; dblerr((int *)&yptr[1]);
	lr->memstatus = 0; dexcn = 1;
	ddtmp = ytest;	/* exception on second word */
	if ((lr->failaddr != (int) &yptr[1]) || (lr->memstatus != 0x182))
		fail(10);

	/* EDAC error in instructions */
	lr->memstatus = 0; dexcn = 1; 
	dumfunc();
	if ((lr->failaddr != (int) dumfunc) || (lr->memstatus != 0x382))
		fail(11);
	flush();
	lr->cachectrl |= 0x0f;        /* enable icache & dcache */
}
	
volatile short a[2] = {1,0};
volatile char x[4] = {0,0,1,2};

memtest()
{

	volatile int wtest = 0;
	int i;

/* test I/O bus exception */

	if (!(lr->leonconf & 0x40)) return(0);
	report(MEM_TEST);

	lr->memcfg1 |= (0x23 << 20); /* enable BEXCN signal */
	dexcn = 1; lr->failaddr = 0; lr->memstatus = 0;
	inb(80,0); /* cause read exception */
	if ((lr->failaddr != (IOAREA + 80)) || (lr->memstatus != 0x180) ||
		(dexcn != 0)) { fail(1); }
	dexcn = 1; lr->failaddr = 0; lr->memstatus = 0;
	inb(72,0); /* cause read exception */
	if ((lr->failaddr != (IOAREA + 72)) || (lr->memstatus != 0x180) ||
		(dexcn != 0)) { fail(2); }
	lr->failaddr = 0; lr->memstatus = 0; dexcn = 1;
	outb(80,0); /* cause write exception */
	if ((lr->failaddr != (IOAREA + 80)) || (lr->memstatus != 0x100) ||
		(dexcn != 0)) { fail(3); }
	lr->failaddr = 0; lr->memstatus = 0; dexcn = 1;
	outb(72,0); /* cause write exception */
	if ((lr->failaddr != (IOAREA + 72)) || (lr->memstatus != 0x100) ||
		(dexcn != 0)) { fail(4); }

/* do some simple byte/half-word checking */

	a[0] = 0x12; a[1] = 0x23;
	if (*(volatile int *)a != 0x00120023) fail(10);
	x[0] = 0x12; x[1] = 0x34; x[2] = 0x56; x[3] = 0x78;
	if (*(int *)x != 0x12345678) fail(11);

/* write protection test */

	if (lr->leonconf & 0x3) {
		report(WP_TEST);
		lr->cachectrl &= ~0x0c;		/* disable data cache */
		lr->writeprot2 = 0;
		lr->writeprot1 = 0xc0007fff | (((int)&wtest) & 0x3fff8000);
		lr->irqclear = 2;

		/* word write error */
		dexcn = 1; lr->failaddr = 0; lr->memstatus = 0;
		wtest = 1;
		if ((lr->failaddr != (int) &wtest) || (lr->memstatus != 0x102) ||
			(wtest == 1) || (dexcn != 0) || ((lr->irqpend & 2) == 0)) { fail(5); }
		lr->failaddr = 0; lr->memstatus = 0; lr->irqclear = 2; 

		/* byte write error */
		dexcn = 1; lr->failaddr = 0; lr->memstatus = 0;
		* (char *) &wtest = 1;
		if ((lr->failaddr != (int) &wtest) || (lr->memstatus != 0x100) ||
			(wtest == 1) || (dexcn != 0) || ((lr->irqpend & 2) == 0)) { fail(6); }
		lr->failaddr = 0; lr->memstatus = 0; lr->irqclear = 2; 

		lr->writeprot2 = 0x80007fff | (((int)&wtest) & 0x3fff8000);
		wtest = 1;
		if (lr->irqpend & 2) { fail(7); }
		lr->writeprot2 = 0;
		lr->writeprot1 ^= 0x00010000;
		wtest = 1;
		if ((lr->irqpend & 2)) { fail(8); }
		lr->writeprot1 = 0; dexcn = 1; lr->writeprot2 = 0x80007fff;
		wtest = 1;
		lr->writeprot2 = 0;
		if ((lr->failaddr != (int) &wtest) || (lr->memstatus != 0x102) ||
			((lr->irqpend & 2) == 0)) { fail(9); }
		flush();
		lr->cachectrl |= 0x0f;        /* enable icache & dcache */
		lr->failaddr = 0; lr->memstatus = 0; lr->irqclear = 2; 

	}
}

int line1(int x);

wp_test()
{
	int i, wpn;

	dexcn = 1;
	asm("wr	%g0, %g0, %asr24");
	if (dexcn == 0) return(0);
	asm("wr	%g0, %g0, %asr25");
	asm("wr	%g0, %g0, %asr26");
	asm("wr	%g0, %g0, %asr27");
	asm("wr	%g0, %g0, %asr28");
	asm("wr	%g0, %g0, %asr29");
	asm("wr	%g0, %g0, %asr30");
	asm("wr	%g0, %g0, %asr31");
	report(WATCH_TEST);

	dexcn = 0;
	stest = 0;
	line1(stest);	
	dexcn = 3;
	set_asr25(0xfffffffc);
	set_asr24(1 | (~3 & (int)line1));
	line1(*(int *)line1);	
	if (dexcn != 2) fail(1);
	set_asr25(0xfffffffe);
	set_asr24((int)&stest);
	stest = 0;
	if (dexcn != 2) fail(2);
	stest += 1;
	if (dexcn != 1) fail(3);
	set_asr25(0xfffffffd);
	stest = 0;
	if (dexcn != 0) fail(4);
	set_asr25(0xfffffffc);
}
