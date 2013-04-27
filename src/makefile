ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel stdlib.rel char.rel movable.rel mob.rel game.rel level.rel edlevel.rel edroom.rel map.rel edmap.rel edtile.rel editor.rel edfloor.rel zbuffer.rel mouse.rel

all : shike2.com leveldef.bin patset0.bin patset1.bin charset0.bin charset1.bin

palete.asm : ..\\gfx\\shike2.pl5
	echo shike2.pl5
	copy ..\\gfx\\shike2.pl5
	db -lPALETES shike2.pl5 > palete.asm
	del shike2.pl5

bload.obj : bload.asm
	echo bload.asm
	as $(ASFLAGS) bload.asm
	ld bload.obj=bload.rel

########################################################
#load pages objects

loadpg10.obj : loadpg10.asm loader.asm shike2.inc bios.inc
	echo loadpg10.asm
	as $(ASFLAGS) loadpg10.asm
	ld /RC000 loadpg10.obj=loadpg10.rel

loadpg9.obj : loadpg9.asm loader.asm shike2.inc bios.inc
	echo loadpg9.asm
	as $(ASFLAGS) loadpg9.asm
	ld /RC000 loadpg9.obj=loadpg9.rel

loadpg8.obj : loadpg8.asm loader.asm shike2.inc bios.inc
	echo loadpg8.asm
	as $(ASFLAGS) loadpg8.asm
	ld /RC000 loadpg8.obj=loadpg8.rel

loadpg7.obj : loadpg7.asm loader.asm shike2.inc bios.inc
	echo loadpg7.asm
	as $(ASFLAGS) loadpg7.asm
	ld /RC000 loadpg7.obj=loadpg7.rel

loadpg1.obj : loadpg1.asm loader.asm shike2.inc bios.inc
	echo loadpg1.asm
	as $(ASFLAGS) loadpg1.asm
	ld /RC000 loadpg1.obj=loadpg1.rel

########################################################
#data objects

charset1.obj : ..\\gfx\\charset1.gl5
	echo charset1.obj
	delgl5 ..\\gfx\\charset1.gl5 charset1.obj

charset0.obj : ..\\gfx\\charset0.gl5
	echo charset0.obj
	delgl5 ..\\gfx\\charset0.gl5 charset0.obj

patset1.obj : ..\\gfx\\patset1.gl5
	echo patset1.gl5
	delgl5 ..\\gfx\\patset1.gl5 patset1.obj

patset0.obj : ..\\gfx\\patset0.gl5
	echo patset0.gl5
	delgl5 ..\\gfx\\patset0.gl5 patset0.obj

leveldef.obj : leveldef.asm level.inc palete.asm
	echo leveldef.asm
	as $(ASFLAGS) leveldef.asm
	ld /R4000 leveldef.obj=leveldef.rel

########################################################
#binary files

charset1.bin : charset1.obj loadpg10.obj bload.obj
	echo charset1.obj
	concat bload.obj + charset1.obj + loadpg10.obj charset1.bin

charset0.bin : charset0.obj loadpg9.obj bload.obj
	echo charset0.obj
	concat bload.obj + charset0.obj + loadpg9.obj charset0.bin

patset1.bin : patset1.obj loadpg8.obj bload.obj
	echo patset1.obj
	concat bload.obj + patset1.obj + loadpg8.obj patset1.bin

patset0.bin : patset0.obj loadpg7.obj bload.obj
	echo patset0.obj
	concat bload.obj + patset0.obj + loadpg7.obj patset0.bin

leveldef.bin : leveldef.obj loadpg1.obj bload.obj
	echo leveldef.rel
	concat bload.obj + leveldef.obj + loadpg1.obj leveldef.bin


##########################################################
#sources

char.rel : char.asm data.inc
	echo char.asm
	as $(ASFLAGS) char.asm

movable.rel : movable.asm bios.inc shike2.inc data.inc level.inc
	echo movable.asm
	as $(ASFLAGS) movable.asm

mob.rel : mob.asm bios.inc shike2.inc data.inc
	echo mob.asm
	as $(ASFLAGS) mob.asm

game.rel : game.asm bios.asm data.inc
	echo game.asm
	as $(ASFLAGS) game.asm

level.rel : level.asm shike2.inc bios.inc level.inc
	echo level.asm
	as $(ASFLAGS) level.asm

edlevel.rel : edlevel.asm shike2.inc level.inc bios.inc event.inc
	echo edlevel.asm
	as $(ASFLAGS) edlevel.asm

edroom.rel : edroom.asm shike2.inc level.inc bios.inc event.inc
	echo edroom.asm
	as $(ASFLAGS) edroom.asm

map.rel : map.asm shike2.inc level.inc bios.inc
	echo map.asm
	as $(ASFLAGS) map.asm

edmap.rel : edmap.asm bios.inc shike2.inc level.inc event.inc
	echo edmap.asm
	as $(ASFLAGS) edmap.asm

edtile.rel : edtile.asm bios.inc shike2.inc level.inc event.inc
	echo edtile.asm
	as $(ASFLAGS) edtile.asm

edfloor.rel : edfloor.asm bios.inc shike2.inc level.inc event.inc
	echo edfloor.asm
	as $(ASFLAGS) edfloor.asm

editor.rel : editor.asm shike2.inc bios.inc level.inc event.inc
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