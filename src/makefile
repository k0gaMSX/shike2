ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel stdlib.rel editor.rel edfloor.rel zbuffer.rel mouse.rel

all : shike2.com leveldef.bin patset0.bin patset1.bin

palete.asm : ..\\gfx\\shike2.pl5
	echo shike2.pl5
	copy ..\\gfx\\shike2.pl5
	db -lPALETES shike2.pl5 > palete.asm
	del shike2.pl5

bload.obj : bload.asm
	echo bload.asm
	as $(ASFLAGS) bload.asm
	ld bload.obj=bload.rel

loadpag8.obj : loadpag8.asm loader.asm shike2.inc bios.inc
	echo loadpag8.asm
	as $(ASFLAGS) loadpag8.asm
	ld /RC000 loadpag8.obj=loadpag8.rel

patset1.bin : patset1.obj loadpag8.obj bload.obj
	echo patset1.obj
	concat bload.obj + patset1.obj + loadpag8.obj patset1.bin

patset1.obj : ..\\gfx\\patset1.gl5
	echo patset1.gl5
	delgl5 ..\\gfx\\patset1.gl5 patset1.obj

loadpag7.obj : loadpag7.asm loader.asm shike2.inc bios.inc
	echo loadpag7.asm
	as $(ASFLAGS) loadpag7.asm
	ld /RC000 loadpag7.obj=loadpag7.rel

patset0.bin : patset0.obj loadpag7.obj bload.obj
	echo patset0.obj
	concat bload.obj + patset0.obj + loadpag7.obj patset0.bin

patset0.obj : ..\\gfx\\patset0.gl5
	echo patset0.gl5
	delgl5 ..\\gfx\\patset0.gl5 patset0.obj


loadpag1.obj : loadpag1.asm loader.asm shike2.inc bios.inc
	echo loadpag1.asm
	as $(ASFLAGS) loadpag1.asm
	ld /RC000 loadpag1.obj=loadpag1.rel

leveldef.bin : leveldef.obj loadpag1.obj bload.obj
	echo leveldef.rel
	concat bload.obj + leveldef.obj + loadpag1.obj leveldef.bin

leveldef.obj : leveldef.asm level.inc palete.asm
	echo leveldef.asm
	as $(ASFLAGS) leveldef.asm
	ld /R4000 leveldef.obj=leveldef.rel

edfloor.rel : edfloor.asm shike2.inc level.inc event.inc
	echo edfloor.asm
	as $(ASFLAGS) edfloor.asm

editor.rel : editor.asm shike2.inc level.inc event.inc
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