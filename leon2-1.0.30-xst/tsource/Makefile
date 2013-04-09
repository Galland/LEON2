NWINDOWS=8
CC=sparc-elf-gcc
CFLAGS=-O2 -g
ASFLAGS=-DNWINDOWS=$(NWINDOWS)
LDFLAGS=-g -N -nostdlib  -T ./linkleon -e _hardreset locore1.o 
LDFLAGSMMU=-g -N -nostdlib  -T ./linkleon -e _hardreset locore1mmu.o 
LIBS=-L/opt/elf/sparc-elf/lib -lgcc -lm

all: tests
tests: locore1.o locore1mmu.o leon_test_mmu.exe leon_test.exe leon_ram.exe leon_full.exe simfiles

cache.o: leon.h test.h
	$(CC) $(CFLAGS) -msoft-float -c cache.c

simfiles: mram.dat ram.dat rom.dat romsdm.dat romsd.dat fram.dat mmram.dat
mmram.dat: leon_test_mmu.exe
	sparc-elf-objcopy --remove-section=.comment leon_test_mmu.exe
	sparc-elf-objdump -s leon_test_mmu.exe > mmram.dat
	sparc-elf-objdump -d leon_test_mmu.exe > mmram.s
	sparc-elf-size leon_test_mmu.exe

ram.dat: leon_test.exe
	sparc-elf-objcopy --remove-section=.comment leon_test.exe
	sparc-elf-objdump -s leon_test.exe > ram.dat
	sparc-elf-objdump -d leon_test.exe > ram.s
	sparc-elf-size leon_test.exe
	sparc-elf-objcopy -O srec lt sdram.rec

mram.dat: leon_ram.exe
	sparc-elf-objcopy --remove-section=.comment leon_ram.exe
	sparc-elf-objdump -s leon_ram.exe > mram.dat
	sparc-elf-objdump -d leon_ram.exe > mram.s
	sparc-elf-size leon_ram.exe

fram.dat: leon_full.exe
	sparc-elf-objcopy --remove-section=.comment leon_full.exe
	sparc-elf-objdump -s leon_full.exe > fram.dat
	sparc-elf-objdump -d leon_full.exe > fram.s
	sparc-elf-size leon_full.exe

rom.dat: boot.exe
	sparc-elf-objdump -s boot.exe > rom.dat
	sparc-elf-objdump -d boot.exe > rom.s
	sparc-elf-size boot.exe
romsdm.dat: bootsdm.exe
	sparc-elf-objdump -s bootsdm.exe > romsdm.dat
	sparc-elf-objdump -d bootsdm.exe > romsdm.s
	sparc-elf-size bootsdm.exe

romsd.dat: bootsd.exe
	sparc-elf-objdump -s bootsd.exe > romsd.dat
	sparc-elf-objdump -d bootsd.exe > romsd.s
boot.exe: boot.o
	sparc-elf-gcc -N -nostdlib -nostdinclude -T linkboot \
	-e _hardreset boot.o -o boot.exe
bootsdm.exe: bootsdm.o
	sparc-elf-gcc -N -nostdlib -nostdinclude -T linkboot \
	-e _hardreset bootsdm.o -o bootsdm.exe

bootsd.exe: bootsd.o
	sparc-elf-gcc -N -nostdlib -nostdinclude -T linkboot \
	-e _hardreset bootsd.o -o bootsd.exe
divtest.o: divtest.c test.h leon.h
	sparc-elf-gcc -O2 -mv8 -c divtest.c

multest.o: multest.c test.h leon.h
	sparc-elf-gcc -O2 -mv8 -c multest.c

#mmu.o: mmu.c test.h leon.h
#	sparc-elf-gcc -g -c mmu.c
#
leon_ram.exe : regtest.o leon_ram.o misc.o ramtest.o dsu.o fpu.o cache.o
	$(CC) $(LDFLAGS) regtest.o leon_ram.o misc.o cache.o \
	dsu.o ramtest.o fpu.o mmu.o mmu_asm.o  $(LIBS) -o leon_ram.exe
	cp leon_ram.exe lr
	sparc-elf-strip leon_ram.exe

leon_full.exe : regtest.o irqctrl.o uart.o leon_full_test.o timers.o cache.o misc.o \
	memtest.o ioport.o fpu.o ramtest.o dsu.o divtest.o multest.o
	$(CC) $(LDFLAGS) regtest.o irqctrl.o uart.o leon_full_test.o timers.o cache.o misc.o \
	dsu.o memtest.o ioport.o fpu.o ramtest.o mmu.o mmu_asm.o \
	divtest.o  multest.o \
	$(LIBS) -o leon_full.exe
	cp leon_full.exe ft
	sparc-elf-strip leon_full.exe

leon_test.exe : regtest.o irqctrl.o uart.o leon_test.o timers.o cache.o misc.o \
	memtest.o ioport.o fpu.o ramtest.o divtest.o multest.o mmu.o mmu_asm.o
	$(CC) $(LDFLAGS) regtest.o irqctrl.o uart.o leon_test.o timers.o cache.o misc.o \
	memtest.o ioport.o fpu.o ramtest.o mmu.o mmu_asm.o \
	divtest.o  multest.o \
	$(LIBS) -o leon_test.exe
	cp leon_test.exe lt
	sparc-elf-strip leon_test.exe

leon_test_mmu.exe : regtest.o irqctrl.o uart.o leon_test_mmu.o timers.o cache.o misc.o \
	memtest.o ioport.o fpu.o ramtest.o divtest.o multest.o mmu.o mmu_asm.o
	$(CC) $(LDFLAGSMMU) regtest.o irqctrl.o uart.o leon_test_mmu.o timers.o cache.o misc.o \
	memtest.o ioport.o fpu.o ramtest.o mmu.o mmu_asm.o \
	divtest.o  multest.o \
	$(LIBS) -o leon_test_mmu.exe
	cp leon_test_mmu.exe ltm
	sparc-elf-strip leon_test_mmu.exe

clean:
	-rm lt *.exe *.o *.s lr ft ltm

# DO NOT DELETE

uart.o: leon.h test.h
leon_test.o: leon.h test.h locore1.o
leon_test_mmu.o: leon.h test.h locore1mmu.o
timer_test.o: leon.h test.h
regtest.o: leon.h test.h
mmu_cache.o: mmu.h leon.h test.h
dma.o: leon.h test.h
misc.o: leon.h
memtest.o: leon.h test.h
ioport.o: leon.h test.h
fpu.o: leon.h test.h
ramtest.o: leon.h test.h
