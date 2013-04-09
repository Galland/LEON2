#include "leon.h"
#include "test.h"

#define SCALERBITS 10
#define SCALERMAX  ((1<<SCALERBITS) - 1)
#define TIMERBITS 24
#define TIMERMAX  ((1<<TIMERBITS )- 1)

timer_test()
{
	/*
        volatile struct lregs *lr = (struct lregs *) PREGS;
        volatile int *msg = (volatile int *) IOAREA;
	*/
        extern volatile char irqtbl[];
        int i, pil;

	report(TIMER_TEST);
	lr->scalerload = -1;
	lr->scalerload = -1;
	if (lr->scalerload != SCALERMAX) fail(1);
	lr->scalercnt = -1;

	lr->irqmask = lr->irqforce = 0;	/* mask interrupts */
	lr->irqclear = -1;	/* clear pending interrupts */
	irqtbl[0] = 1;		/* init irqtable */

/* timer 1 test */

	lr->scalerload = 31;
	lr->scalercnt = 31;
	lr->timercnt1 = 0;
	lr->timercnt2 = 0;
	lr->timerload1 = 15;
	lr->timerload2 = 15;
	lr->timerctrl1 = 0x6;
//	lr->timerctrl2 = 0;
	if (lr->timercnt1 != 15) fail(3);
	lr->timerctrl1 = 0x7;
	for (i=14; i >= 0; i--) { while (lr->timercnt1 != i) {}}
	while (lr->timercnt1 != 15) {}

	if (!((lr->irqpend == 0x100) && (irqtbl[0] == 1))) fail(4);
	lr->irqclear = 0x100;	/* clear pending timer interrupt */
	if (lr->irqpend) fail(5);
	lr->timerctrl1 = 0x1;	/* disable reload */
	lr->scalerload = 2;
	lr->scalercnt = 2;
	while (lr->timerctrl1) {}
	if (!((lr->irqpend == 0x100) && (irqtbl[0] == 1))) fail(6);
	lr->irqclear = 0x100;	/* clear pending timer interrupt */

/* timer 2 test */

	lr->scalerload = 31;
	lr->scalercnt = 31;
	lr->timerload2 = 15;
	lr->timerctrl2 = 0x6;
	if (lr->timercnt2 != 15) fail(7);
	lr->timerctrl2 = 0x7;
	for (i=14; i >= 0; i--) { while (lr->timercnt2 != i) {}}
	while (lr->timercnt2 != 15) {}

	if (!((lr->irqpend == 0x200) && (irqtbl[0] == 1))) fail(8);
	lr->irqclear = 0x200;	/* clear pending timer interrupt */
	if (lr->irqpend) fail(9);
	lr->timerctrl2 = 0x1;	/* disable reload */
	lr->scalerload = 2;
	lr->scalercnt = 2;
	while (lr->timerctrl2) {}
	if (!((lr->irqpend == 0x200) && (irqtbl[0] == 1))) fail(10);
	lr->irqclear = 0x200;	/* clear pending timer interrupt */

/* watchdog test */

        if (lr->leonconf & 0x080) {
	  lr->wdog = 128;
	  if (!lr->wdog) fail(11);
	  lr->wdog = 31;
	  lr->piodir = 0;
	  lr->piodir = 0;
	  lr->piodir &= ~0x8;
	  while (lr->piodata & 0x8) {}
	  if (lr->wdog) fail(12);
	  lr->wdog = -1;
	}

/* power-down test */

	lr->irqforce = 0;	/* clear forced interrupts */
	lr->irqclear = -1;	/* clear pending interrupts */
	lr->irqmask = 0x100;	/* unmask timer 1 interrupt */
	irqtbl[0] = 1;		/* init irqtable */
	lr->scalerload = 31;
	lr->scalercnt = 31;
	lr->timerload1 = 15;
	lr->timerctrl1 = 0x5;
	lr->timerctrl1 = 0x5;
	lr->powerdown = 0;
	lr->powerdown = 0;
	if (lr->timercnt1 != 0) fail(13);
	lr->irqclear = -1;	/* clear pending interrupts */
	lr->irqmask = 0;	/* mask interrupts */
	irqtbl[0] = 1;		/* init irqtable */

	lr->timerctrl1 = 0;	/* turn off timers */
	lr->timerctrl2 = 0;
	
}
