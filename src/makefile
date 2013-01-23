DEP = shike2.rel vdp.rel kbd.rel bios.rel editor.rel iso.rel geometry.rel
REL = shike2.rel,vdp.rel,kbd.rel,bios.rel,editor.rel,iso.rel,geometry.rel
ASFLAGS = -t

all : shike2.com

geometry.rel : geometry.asm vdp.inc bios.inc
	as $(ASFLAGS) geometry.asm

iso.rel : iso.asm iso.inc shike2.inc bios.inc
	as $(ASFLAGS) iso.asm

vdp.rel : vdp.asm shike2.inc bios.inc vdp.inc
	as $(ASFLAGS) vdp.asm

shike2.rel : shike2.asm shike2.inc bios.inc
	as $(ASFLAGS) shike2.asm

bios.rel : bios.asm dos.inc
	as $(ASFLAGS) bios.asm

kbd.rel : kbd.asm shike2.inc bios.inc
	as $(ASFLAGS) kbd.asm

editor.rel : editor.asm shike2.inc bios.inc iso.inc kbd.inc
	as $(ASFLAGS) editor.asm

shike2.com : $(DEP)
	ld /R4000 /P4000 /D6000 /X /Gmain $(REL)

clean :
	del *.rel
	del *.sym
	del *.com
