ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel movable.rel editor.rel level.rel edlevel.rel edheigth.rel heigth.rel edmapper.rel mapper.rel geometry.rel mob.rel game.rel stdlib.rel

all : shike2.com

char.rel : char.asm
	echo char.asm
	as $(ASFLAGS) char.asm

stdlib.rel : stdlib.asm
	echo stdlib.asm
	as $(ASFLAGS) stdlib.asm

game.rel : game.asm shike2.inc kbd.inc
	echo game.asm
	as $(ASFLAGS) game.asm

mob.rel : mob.asm bios.inc  shike2.inc
	echo mob.asm
	as $(ASFLAGS) mob.asm

geometry.rel : geometry.asm  bios.inc kbd.inc geometry.inc
	echo geometry.asm
	as $(ASFLAGS) geometry.asm

mapper.rel : mapper.asm editor.inc shike2.inc bios.inc
	echo mapper.asm
	as $(ASFLAGS) mapper.asm

vdp.rel : vdp.asm shike2.inc bios.inc
	echo vdp.asm
	as $(ASFLAGS) vdp.asm

movable.rel : movable.asm geometry.inc bios.inc movable.inc
	echo movable.asm
	as $(ASFLAGS) movable.asm

shike2.rel : shike2.asm shike2.inc bios.inc
	echo shike2.asm
	as $(ASFLAGS) shike2.asm

edlevel.rel : edlevel.asm editor.inc shike2.inc bios.inc kbd.inc
	echo edlevel.asm
	as $(ASFLAGS) edlevel.asm

level.rel : level.asm editor.inc shike2.inc geometry.inc
	echo level.rel
	as $(ASFLAGS) level.asm

edheigth.rel : edheigth.asm shike2.inc editor.inc bios.inc geometry.inc kbd.inc
	echo edheight.asm
	as $(ASFLAGS) edheigth.asm

heigth.rel : heigth.asm shike2.inc editor.inc
	echo height.asm
	as $(ASFLAGS) heigth.asm

editor.rel : editor.asm bios.inc editor.inc shike2.inc 
	echo editor.asm
	as $(ASFLAGS) editor.asm

bios.rel : bios.asm bios.inc
	echo bios.asm
	as $(ASFLAGS) bios.asm

kbd.rel : kbd.asm shike2.inc bios.inc
	echo kbd.asm
	as $(ASFLAGS) kbd.asm

editor.rel : editor.asm bios.inc editor.inc shike2.inc
	as $(ASFLAGS) editor.asm

edmapper.rel : edmapper.asm shike2.inc bios.inc editor.inc kbd.inc geometry.inc
	echo edmapper.asm
	as $(ASFLAGS) edmapper.asm

shike2.com : $(REL)
	ld /R4000 /P4000 /D0100 /X /Gmain & <ld.cmd

clean :
	del *.rel
	del *.sym
	del *.com

