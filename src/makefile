DEP = shike2.rel vdp.rel kbd.rel bios.rel debug.rel editor.rel
REL = shike2.rel,vdp.rel,kbd.rel,bios.rel,debug.rel,editor.rel
H = shike2.inc bios.inc dos.inc

all : shike2.com

debug.rel : debug.asm $H
	as debug.asm

vdp.rel : vdp.asm $H
	as vdp.asm

shike2.rel : shike2.asm $H
	as shike2.asm

bios.rel : bios.asm $H
	as bios.asm

kbd.rel : kbd.asm $H
	as kbd.asm

editor.rel : editor.asm
	as editor.asm

shike2.com : $(DEP)
	ld /R4000 /P4000 /D6000 /X /Gmain $(REL)

clean :
	del *.rel
	del *.sym
	del *.com
