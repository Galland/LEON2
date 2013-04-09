
#include "leon.h"
#include "test.h"

int ioport_test()
{
    
    /* report start of test */
    report(PIO_TEST);

    /* initialise registers */

    lr->piodata = 0;
    lr->piodir = 0;
    lr->pioirq = 0;
    lr->uartctrl1 = 0;
    lr->uartctrl2 = 0;


    /* check that port can be read & written */
    lr->piodata = 0xaa55;
    lr->piodir = 0xffff;
    if ((lr->piodata & 0x0ffff) != 0xaa55) fail(1);
    lr->piodata = 0x55aa;
    if ((lr->piodata & 0x0ffff) != 0x55aa) fail(2);
    lr->piodata = 0x0;
    if ((lr->piodata & 0x0ffff) != 0) fail(3);
    lr->piodata = 0x1234;
    if ((lr->piodata & 0x0ffff) != 0x1234) fail(4);
    lr->piodata = ~0x1234;
    if ((lr->piodata & 0x0ffff) != (0xffff & ~0x1234)) fail(5);

    /* check pio[31:16] in case we are in 16-bit mode */

    if (((lr->memcfg1 & 0x200) || (lr->memcfg2 & 0x4020)) == 0) {
	lr->memcfg1 &= ~(1<<28);
        lr->piodata = 0x12345678;
        lr->piodir = 0x3ffff;
        lr->piodir = 0x3ffff; /* artificial delay */
        if (lr->piodata != 0x12345678) fail(6);
        lr->piodata = ~lr->piodata;
        lr->piodata = lr->piodata; /* artificial delay */
        if (lr->piodata != ~0x12345678) fail(7);
	lr->memcfg1 |= (1<<28);
    }

    /* check port interrupts */

    lr->piodata = 0;
    lr->irqclear = -1;	/* clear all pending interrupts */
    lr->pioirq = 0xe3c2a180;
    lr->irqclear = -1;	
    if ((lr->irqpend & 0x0f0) != (1<<4)) fail(8);
    lr->piodata = -1;
    lr->piodata = -1;	/* add delay */
    if ((lr->irqpend & 0x0f0) != ((1<<7) | (1<<5) | (1<<4))) fail(9);
    lr->irqclear = -1;	
    if ((lr->irqpend & 0x0f0) != (1<<5)) fail(10);
    lr->piodata = 0;
    lr->piodata = 0;
    if ((lr->irqpend & 0x0f0) != ((1<<6) | (1<<5) | (1<<4))) fail(11);
    lr->irqclear = -1;	
    if ((lr->irqpend & 0x0f0) != (1<<4)) fail(12);
    lr->piodir = 0;
    lr->pioirq = 0;
    lr->irqclear = -1;	
    

}
