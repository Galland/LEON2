
#include <stdio.h>

main()
{
	int i = 0;
	unsigned char tc;
	int tmp;
	while (!feof(stdin)) {
		tc = getchar() & 0x0ff;
		tmp = (tmp << 8) | tc;
		i++;
		if (i == 4) { 
			for (i=0; i<32; i++) {
				if (tmp < 0) putchar('1');
				else putchar('0');
				tmp <<= 1;
			}
			putchar('\n');
			i = 0;
		}
	}
	exit(0);
}
