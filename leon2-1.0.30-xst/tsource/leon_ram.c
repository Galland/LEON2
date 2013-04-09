#include "leon.h"
#include "test.h"

leon_test()
{
	
	report(SYS_TEST);

	report(RAM_INIT);
	ramfill();
	ramtest();
	report(REG_TEST);
	if (regtest() != 1) fail(1);
	dsu_ram_test(); 
	report(TEST_END);
}
