ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel stdlib.rel editor.rel edfloor.rel zbuffer.rel mouse.rel

all : shike2.com leveldef.bin

bload.obj : bload.asm
	echo bload.asm
	as $(ASFLAGS) bload.asm
	ld bload.obj=bload.rel

loader.obj : loader.asm
	echo loader.asm
	as $(ASFLAGS) loader.asm
	ld /RC000 loader.obj=loader.rel

palete.asm : ..\\gfx\\shike2.pl5
	echo shike2.pl5
	copy ..\\gfx\\shike2.pl5
	db -lPALETES shike2.pl5 > palete.asm
	del shike2.pl5

leveldef.bin : leveldef.obj loader.obj bload.obj
	echo leveldef.rel
	concat bload.obj + leveldef.obj + loader.obj leveldef.bin

leveldef.obj : leveldef.asm level.inc palete.asm
	echo leveldef.asm
	as $(ASFLAGS) leveldef.asm
	ld /R4000 leveldef.obj=leveldef.rel

edfloor.rel : edfloor.asm bios.inc
	echo edfloor.asm
	as $(ASFLAGS) edfloor.asm

editor.rel : editor.asm bios.inc
	echo editor.asm
	as $(ASFLAGS) editor.asm

mouse.rel : mouse.asm bios.inc sprite.inc shike2.inc
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

kbd.rel : kbd.asm shike2.inc bios.inc event.inc
	echo kbd.asm
	as $(ASFLAGS) kbd.asm

shike2.com : $(REL)
	ld /R0100 /P0100 /D8000 /X /Gmain & <ld.cmd

clean :
	del *.rel
	del *.sym
	del *.com
	del *.bin
	del *.obj
	del palete.asm

