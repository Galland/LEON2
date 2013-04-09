
# Make sure that TOP64K and MKPROMOPT reflect your hardware !!

CC=gcc

# Top 64 kbyte of ram, reserved for rdbmon stack and data
TOP64K = 0x403f0000

# mkprom options
MKPROMOPT = -ramsize 4096 -romsize 512 -ramcs 2 -freq 24.576 -romws 1 -rmw \
	    -ramwidth 32 -baud 38400

all: rom2vhdl bprom.vhd eprom.srec virtex_prom2048.mif

bin2mif: bin2mif.c
	$(CC) bin2mif.c -o bin2mif

rom2vhdl: rom2vhdl.c
	$(CC) rom2vhdl.c -o rom2vhdl

bprom.vhd: rom2vhdl bin2mif bprom.c
	sparc-rtems-gcc -nostdlib -nostdinc -O2 -Ttext=0 bprom.c -o bprom.exe
	sparc-rtems-objcopy -O binary bprom.exe bprom.bin
	./rom2vhdl bprom.bin -o bprom.vhd
	./bin2mif < bprom.bin > virtex_prom256.mif

eprom.srec: eprom.c
	sparc-rtems-gcc -nostdlib -nostdinc -O2 -Ttext=0 eprom.c -o eprom.exe
	sparc-rtems-objcopy -O srec eprom.exe eprom.srec

virtex_prom2048.mif: lmon.o bin2mif 
	sparc-rtems-gcc -O2 -qprom -Tdata=$(TOP64K) lmon.o -o lmon.exe
	mkprom $(MKPROMOPT) lmon.exe -o virtex_prom2048.exe
	sparc-rtems-objcopy -O binary virtex_prom2048.exe virtex_prom2048.bin
	./bin2mif < virtex_prom2048.bin > virtex_prom2048.mif

clean:
	-rm -f rom2vhdl bprom.vhd bprom bprom.bin eprom eprom.srec *.mif \
	*.bin *.exe bin2mif virtex* prom.out

