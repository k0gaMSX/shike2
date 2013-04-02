ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel stdlib.rel zbuffer.rel mouse.rel

all : shike2.com leveldef.bin

leveldef.bin : leveldef.asm loader.asm
	echo leveldef.asm
	as $(ASFLAGS) leveldef.asm
	ld /B8000 /R8000 /Gmain leveldef.bin=leveldef.rel

mouse.rel : mouse.asm bios.inc sprite.inc
	echo mouse.asm
	as $(ASFLAGS) mouse.asm

zbuffer.rel : zbuffer.asm
	echo zbuffer.asm
	as $(ASFLAGS) zbuffer.asm

stdlib.rel : stdlib.asm shike2.inc bios.inc
	echo stdlib.asm
	as $(ASFLAGS) stdlib.asm

vdp.rel : vdp.asm shike2.inc bios.inc
	echo vdp.asm
	as $(ASFLAGS) vdp.asm

shike2.rel : shike2.asm shike2.inc bios.inc
	echo shike2.asm
	as $(ASFLAGS) shike2.asm

bios.rel : bios.asm bios.inc
	echo bios.asm
	as $(ASFLAGS) bios.asm

kbd.rel : kbd.asm shike2.inc bios.inc
	echo kbd.asm
	as $(ASFLAGS) kbd.asm

shike2.com : $(REL)
	ld /R0100 /P0100 /D8000 /X /Gmain & <ld.cmd

clean :
	del *.rel
	del *.sym
	del *.com
	del *.bin

