#include "leon.h"
struct lregs *lr = (struct lregs *) PREGS;
unsigned char *msg = (unsigned char *) IOAREA; 
//unsigned char *msg = (unsigned char *) CRAM; 
unsigned short *msgh = (unsigned short *) IOAREA; 
unsigned int *msgw = (unsigned int *) IOAREA; 
unsigned long long *msgd = (unsigned long long *) IOAREA; 
int test ;
int dummy[4] = {0,0,0,0};

fail(err) int err; { msg[test] = err; }
report(test_case) int test_case; { test = test_case; msg[test] = 0; }

int getpsr(void) {
	unsigned long retval;
	__asm__ __volatile__("rd	%%psr, %0" : "=r" (retval));
	return retval;
}

void setpsr(int psr) {
	__asm__ __volatile__(
	"wr	%0, 0x0, %%psr\n\t"
	"nop; nop; nop\n"
	: : "r" (psr)
	: "memory", "cc");
}

unsigned char inb(a) int a; { return(msg[a]); }
outb(a,d) int a; char d; { msg[a] = d; }
unsigned short inh(a) int a; { return(msgh[a]); }
outh(a,d) int a; short d; { msgh[a] = d; }
unsigned int inw(a) int a; { return(msgw[a]); }
outw(a,d) int a; short d; { msgw[a] = d; }
unsigned long long ind(a) int a; { return(msgd[a]); }
outd(a,d) int a; short d; { msgd[a] = d; }

asm("
	.global _get_fsr, _set_fsr
	.global get_fsr, set_fsr
	.data
fsrtmp:	.word 0
	.text
_get_fsr:
get_fsr:
	set	fsrtmp, %o0
	st	%fsr, [%o0]
	retl
	ld	[%o0], %o0
_set_fsr:
set_fsr:
	set	fsrtmp, %o1
	st	%o0, [%o1]
	retl
	ld	[%o1], %fsr
	.global get_asr24
get_asr24:
	retl; mov	%asr24, %o0;
	.global get_asr25
get_asr25:
	retl; mov	%asr25, %o0;
	.global get_asr26
get_asr26:
	retl; mov	%asr26, %o0;
	.global get_asr27
get_asr27:
	retl; mov	%asr27, %o0;
	.global get_asr28
get_asr28:
	retl; mov	%asr28, %o0;
	.global get_asr29
get_asr29:
	retl; mov	%asr29, %o0;
	.global get_asr30
get_asr30:
	retl; mov	%asr30, %o0;
	.global get_asr31
get_asr31:
	retl; mov	%asr31, %o0;
	.global set_asr24
set_asr24:
	retl; mov	%o0, %asr24;
	.global set_asr25
set_asr25:
	retl; mov	%o0, %asr25;
	.global set_asr26
set_asr26:
	retl; mov	%o0, %asr26;
	.global set_asr27
set_asr27:
	retl; mov	%o0, %asr27;
	.global set_asr28
set_asr28:
	retl; mov	%o0, %asr28;
	.global set_asr29
set_asr29:
	retl; mov	%o0, %asr29;
	.global set_asr30
set_asr30:
	retl; mov	%o0, %asr30;
	.global set_asr31
set_asr31:
	retl; mov	%o0, %asr31;
");
