ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel editor.rel bios.rel edmapper.rel mapper.rel geometry.rel mob.rel game.rel char.rel stdlib.rel

all : shike2.com

char.rel : char.asm
	echo char.asm
	as $(ASFLAGS) char.asm

stdlib.rel : stdlib.asm
	echo stdlib.asm
	as $(ASFLAGS) stdlib.asm

game.rel : game.asm shike2.inc bios.inc
	echo game.asm
	as $(ASFLAGS) game.asm

mob.rel : mob.asm bios.inc vdp.inc shike2.inc
	echo mob.asm
	as $(ASFLAGS) mob.asm

geometry.rel : geometry.asm vdp.inc bios.inc kbd.inc geometry.inc
	echo geometry.asm
	as $(ASFLAGS) geometry.asm

mapper.rel : mapper.asm editor.inc shike2.inc bios.inc
	echo mapper.asm
	as $(ASFLAGS) mapper.asm

vdp.rel : vdp.asm shike2.inc bios.inc vdp.inc
	echo vdp.asm
	as $(ASFLAGS) vdp.asm

shike2.rel : shike2.asm shike2.inc bios.inc
	echo shike2.asm
	as $(ASFLAGS) shike2.asm

editor.rel : editor.asm bios.inc editor.inc shike2.inc
	echo editor.asm
	as $(ASFLAGS) editor.asm

bios.rel : bios.asm dos.inc
	echo bios.asm
	as $(ASFLAGS) bios.asm

kbd.rel : kbd.asm shike2.inc bios.inc
	echo kbd.asm
	as $(ASFLAGS) kbd.asm


edmapper.rel : edmapper.asm shike2.inc bios.inc editor.inc kbd.inc geometry.inc
	echo edmapper.asm
	as $(ASFLAGS) edmapper.asm

shike2.com : $(REL)
	ld /R4000 /P4000 /D6000 /X /Gmain & <ld.cmd

clean :
	del *.rel
	del *.sym
	del *.com

