DEP = shike2.rel vdp.rel kbd.rel bios.rel editor.rel mapper.rel geometry.rel mob.rel game.rel
REL = shike2.rel,vdp.rel,kbd.rel,bios.rel,editor.rel,mapper.rel,geometry.rel,mob.rel,game.rel
ASFLAGS = -t

all : shike2.com

game.rel : game.asm shike2.inc bios.inc
	as $(ASFLAGS) game.asm

mob.rel : mob.asm bios.inc vdp.inc shike2.inc
	as $(ASFLAGS) mob.asm

geometry.rel : geometry.asm vdp.inc bios.inc kbd.inc geometry.inc
	as $(ASFLAGS) geometry.asm

mapper.rel : mapper.asm mapper.inc shike2.inc bios.inc
	as $(ASFLAGS) mapper.asm

vdp.rel : vdp.asm shike2.inc bios.inc vdp.inc
	as $(ASFLAGS) vdp.asm

shike2.rel : shike2.asm shike2.inc bios.inc
	as $(ASFLAGS) shike2.asm

bios.rel : bios.asm dos.inc
	as $(ASFLAGS) bios.asm

kbd.rel : kbd.asm shike2.inc bios.inc
	as $(ASFLAGS) kbd.asm

editor.rel : editor.asm shike2.inc bios.inc mapper.inc kbd.inc geometry.inc
	as $(ASFLAGS) editor.asm

shike2.com : $(DEP)
	ld /R4000 /P4000 /D6000 /X /Gmain $(REL)

clean :
	del *.rel
	del *.sym
	del *.com
