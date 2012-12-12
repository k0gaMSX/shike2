REL = vdp.rel kbd.rel shike2.rel bios.rel debug.rel
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

shike2.com : $(REL)
	ld /D6000 /X /Gmain shike2.rel,kbd.rel,vdp.rel,bios.rel,debug.rel

clean :
	del *.rel
	del *.sym
	del *.com
