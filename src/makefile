ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel edheigth.rel heigth.rel edmapper.rel mapper.rel geometry.rel mob.rel game.rel char.rel stdlib.rel

all : shike2.com

char.rel : char.asm
	as $(ASFLAGS) char.asm

stdlib.rel : stdlib.asm
	as $(ASFLAGS) stdlib.asm

game.rel : game.asm shike2.inc bios.inc
	as $(ASFLAGS) game.asm

mob.rel : mob.asm bios.inc vdp.inc shike2.inc
	as $(ASFLAGS) mob.asm

geometry.rel : geometry.asm vdp.inc bios.inc kbd.inc geometry.inc
	as $(ASFLAGS) geometry.asm

mapper.rel : mapper.asm editor.inc shike2.inc bios.inc
	as $(ASFLAGS) mapper.asm

vdp.rel : vdp.asm shike2.inc bios.inc vdp.inc
	as $(ASFLAGS) vdp.asm

shike2.rel : shike2.asm shike2.inc bios.inc
	as $(ASFLAGS) shike2.asm

edheigth.rel : edheigth.asm shike2.inc editor.inc bios.inc
	as $(ASFLAGS) edheigth.asm

heigth.rel : heigth.asm shike2.inc editor.inc
	as $(ASFLAGS) heigth.asm

bios.rel : bios.asm dos.inc
	as $(ASFLAGS) bios.asm

kbd.rel : kbd.asm shike2.inc bios.inc
	as $(ASFLAGS) kbd.asm

editor.rel: editor.asm bios.inc editor.inc shike2.inc
	as $(ASFLAGS) editor.asm

edmapper.rel : edmapper.asm shike2.inc bios.inc editor.inc kbd.inc geometry.inc
	as $(ASFLAGS) edmapper.asm

shike2.com : $(REL)
	ld /R4000 /P4000 /D6000 /X /Gmain & <ld.cmd

clean :
	del *.rel
	del *.sym
	del *.com
