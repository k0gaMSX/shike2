ASFLAGS = -t
REL =	shike2.rel vdp.rel kbd.rel bios.rel stdlib.rel char.rel talk.rel edtile.rel edfloor.rel movable.rel mob.rel game.rel level.rel edlevel.rel edroom.rel map.rel edmap.rel editor.rel zbuffer.rel mouse.rel

all : shike data

shike : shike2.com

data : leveldef.bin patset0.bin patset1.bin charset0.bin charset1.bin map0.bin map1.bin map2.bin map3.bin height0.bin height1.bin

dist : clean
	a:\\utils\\comp\\lhpack a shike2.lzh *.*

palete.asm : ..\\gfx\\shike2.pl5
	echo shike2.pl5
	copy ..\\gfx\\shike2.pl5
	db -lPALETES shike2.pl5 > palete.asm
	del shike2.pl5

fontspr.asm : font.obj
	echo font.obj
	fon2spr -lFONTSPR font.obj > fontspr.asm

font.asm : font.obj
	echo font.obj
	db -lFONT font.obj > font.asm

bload.obj : bload.asm
	echo bload.asm
	as $(ASFLAGS) bload.asm
	ld bload.obj=bload.rel

########################################################
#load pages objects

loadpg11.obj : loadpg11.asm loader.asm shike2.inc bios.inc
	echo loadpg11.asm
	as $(ASFLAGS) loadpg11.asm
	ld /RC000 loadpg11.obj=loadpg11.rel

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

loadpg6.obj : loadpg6.asm loader.asm shike2.inc bios.inc
	echo loadpg6.asm
	as $(ASFLAGS) loadpg6.asm
	ld /RC000 loadpg6.obj=loadpg6.rel

loadpg5.obj : loadpg5.asm loader.asm shike2.inc bios.inc
	echo loadpg5.asm
	as $(ASFLAGS) loadpg5.asm
	ld /RC000 loadpg5.obj=loadpg5.rel

loadpg4.obj : loadpg4.asm loader.asm shike2.inc bios.inc
	echo loadpg4.asm
	as $(ASFLAGS) loadpg4.asm
	ld /RC000 loadpg4.obj=loadpg4.rel

loadpg3.obj : loadpg3.asm loader.asm shike2.inc bios.inc
	echo loadpg3.asm
	as $(ASFLAGS) loadpg3.asm
	ld /RC000 loadpg3.obj=loadpg3.rel

loadpg2.obj : loadpg2.asm loader.asm shike2.inc bios.inc
	echo loadpg2.asm
	as $(ASFLAGS) loadpg2.asm
	ld /RC000 loadpg2.obj=loadpg2.rel

loadpg1.obj : loadpg1.asm loader.asm shike2.inc bios.inc
	echo loadpg1.asm
	as $(ASFLAGS) loadpg1.asm
	ld /RC000 loadpg1.obj=loadpg1.rel

########################################################
#data objects

font.obj : ..\\gfx\\font.gl5
	echo font.gl5
	del font.obj > NUL
	delgl5 ..\\gfx\\font.gl5 font.obj

charset1.obj : ..\\gfx\\charset1.gl5
	echo charset1.obj
	del charset1.obj > NUL
	delgl5 ..\\gfx\\charset1.gl5 charset1.obj

charset0.obj : ..\\gfx\\charset0.gl5
	echo charset0.obj
	del charset0.obj > NUL
	delgl5 ..\\gfx\\charset0.gl5 charset0.obj

patset1.obj : ..\\gfx\\patset1.gl5
	echo patset1.gl5
	del patset1.obj > NUL
	delgl5 ..\\gfx\\patset1.gl5 patset1.obj

patset0.obj : ..\\gfx\\patset0.gl5
	echo patset0.gl5
	del patset0.obj > NUL
	delgl5 ..\\gfx\\patset0.gl5 patset0.obj

leveldef.obj : leveldef.asm level.inc palete.asm font.asm
	echo leveldef.asm
	as $(ASFLAGS) leveldef.asm
	ld /R4000 leveldef.obj=leveldef.rel

########################################################
#binary files


map0.bin : map0.dat loadpg2.obj bload.obj
	echo map0.dat
	concat /B bload.obj + map0.dat + loadpg2.obj map0.bin

map1.bin : map1.dat loadpg3.obj bload.obj
	echo map1.dat
	concat /B bload.obj + map1.dat + loadpg3.obj map1.bin

map2.bin : map2.dat loadpg4.obj bload.obj
	echo map2.dat
	concat /B bload.obj + map2.dat + loadpg4.obj map2.bin

map3.bin : map3.dat loadpg5.obj bload.obj
	echo map3.dat
	concat /B bload.obj + map3.dat + loadpg5.obj map3.bin

height0.bin : height0.dat loadpg6.obj bload.obj
	echo height0.dat
	concat /B bload.obj + height0.dat + loadpg6.obj height0.bin

height1.bin : height1.dat loadpg7.obj bload.obj
	echo height1.dat
	concat /B bload.obj + height1.dat + loadpg7.obj height1.bin

charset1.bin : charset1.obj loadpg11.obj bload.obj
	echo charset1.obj
	concat /B bload.obj + charset1.obj + loadpg11.obj charset1.bin

charset0.bin : charset0.obj loadpg10.obj bload.obj
	echo charset0.obj
	concat /B bload.obj + charset0.obj + loadpg10.obj charset0.bin

patset1.bin : patset1.obj loadpg9.obj bload.obj
	echo patset1.obj
	concat /B bload.obj + patset1.obj + loadpg9.obj patset1.bin

patset0.bin : patset0.obj loadpg8.obj bload.obj
	echo patset0.obj
	concat /B bload.obj + patset0.obj + loadpg8.obj patset0.bin

leveldef.bin : leveldef.obj loadpg1.obj bload.obj
	echo leveldef.rel
	concat /B bload.obj + leveldef.obj + loadpg1.obj leveldef.bin


##########################################################
#sources

talk.rel : talk.asm sprite.inc fontspr.asm data.inc
	echo talk.asm
	as $(ASFLAGS) talk.asm

char.rel : char.asm bios.inc data.inc event.inc
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

edtile.rel : edtile.asm bios.inc shike2.inc event.inc level.inc
	echo edtile.asm
	as $(ASFLAGS) edtile.asm

edfloor.rel : edfloor.asm bios.inc shike2.inc event.inc level.inc
	echo edfloor.asm
	as $(ASFLAGS) edfloor.asm

edmap.rel : edmap.asm bios.inc shike2.inc level.inc event.inc sprite.inc
	echo edmap.asm
	as $(ASFLAGS) edmap.asm

editor.rel : editor.asm shike2.inc bios.inc level.inc event.inc
	echo editor.asm
	as $(ASFLAGS) editor.asm

mouse.rel : mouse.asm bios.inc sprite.inc shike2.inc
	echo mouse.asm
	as $(ASFLAGS) mouse.asm

zbuffer.rel : zbuffer.asm shike2.inc bios.inc
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
	del *.rel > NUL
	del *.sym > NUL
	del *.com > NUL
	del *.bin > NUL
	del *.obj > NUL
	del shike2.lzh > NUL
	del palete.asm > NUL
	del font.asm > NUL
	del fontspr.asm > NUL
	del *.bat > NUL

