
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDMAP
	EXTRN	CARTPAGE,EDINIT,VDPSYNC,LISTEN

EDMAP:	CALL	ADDRECEIVERS
ED.LOOP:CALL	EDINIT

	LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

	EXTRN	ED.TILE,ED.FLOOR,PALEVENT,SETEVENT

RECEIVERS:
	DB	1,29,142,8
	DW	PALEVENT
	DB	1,29,150,8
	DW	SETEVENT
	DB	220,16,126,16
	DW	ED.FLOOR
	DB	220,16,150,48
	DW	ED.TILE
R.FLOOR:DS	64*6
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

ADDRECEIVERS:
	LD	HL,R.FLOOR
	LD	(A.PTR),HL
	LD	DE,0
	LD	B,8

A.LOOPY:PUSH	BC			;RUN OVER Y
	PUSH	DE
	LD	B,8

A.LOOPX:PUSH	BC			;RUN OVER X
	PUSH	DE
	CALL	ISOVIEW			;TRANSFORM TO SCREEN COORDENATES
	EX	DE,HL
	LD	HL,(A.PTR)
	LD	A,ISOX			;ADD THE SCREEN OFFSET
	ADD	A,D
	INC	A			;AVOID X = 0
	LD	(HL),A
	INC	HL
	LD	(HL),15
	INC	HL
	LD	A,ISOY
	ADD	A,E
	LD	(HL),A
	INC	HL
	LD	(HL),16
	INC	HL
	LD	DE,POSEVENT
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(A.PTR),HL
	POP	DE
	INC	D
	POP	BC
	DJNZ	A.LOOPX			;NEXT X

	POP	DE
	INC	E
	POP	BC
	DJNZ	A.LOOPY			;NEXT Y
	RET

	DSEG

A.PTR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	DRAWSTACKS,EDTILE,EDFLOOR,EDSET,EDPAL,GLINES,LOCATE,PRINTF

SHOWSCR:CALL	FGRID			;DRAW FLOOR GRID
	LD	DE,18
	CALL	LOCATE

	LD	H,0
	LD	DE,(LEVEL)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	DE,(ROOM)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	A,(HEIGHT)
	LD	L,A
	PUSH	HL
	LD	DE,(MAP)
	PUSH	DE
	LD	A,(EDSET)
	LD	L,A
	PUSH	HL
	LD	A,(EDPAL)
	LD	L,A
	PUSH	HL
	LD	DE,FMT
	CALL	PRINTF			;PRINT INFORMATION

	LD	DE,MAPG
	LD	C,15
	CALL	GLINES

	LD	DE,(EDFLOOR)
	CALL	GETFLOOR
	LD	E,FLOORYSIZ
	LD	BC,220*256 + 126
	CALL	DRAWSTACKS

	LD	HL,(EDTILE)
	CALL	GETTILE
	LD	DE,TILE.MAP
	ADD	HL,DE
	LD	E,TILEYSIZ
	LD	BC,220*256 + 150
	JP	DRAWSTACKS


FMT:	DB	" PALETE",9,"  %3d",10
	DB	" SET",9,"  %3d",10
	DB	" MAP",9," %04d",10
	DB	" HEIGHT",9,"   %02d",10
	DB	" ROOM",9,"%02dX%02d",10
	DB	" LEVEL",9,"%02dX%02d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
MAPG:	DB	5,  0, 142,   30,142,  0,  8,  0,  8
	DB	2,  0, 142,    0,174, 30,  0, 30,  0
	DB	2,220, 126,  236,126,  0, 16,  0, 16
	DB	2,220, 126,  220,142, 16,  0, 16,  0
	DB	2,220, 150,  236,150,  0, 48,  0, 48
	DB	2,220, 150,  220,198, 16,  0, 16,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

ISOX	EQU	112
ISOY	EQU	32


FGRID:	LD	DE,0
	LD	B,8

S.LOOPY:PUSH	BC			;LOOP OVER Y
	PUSH	DE
	LD	B,8

S.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	DE
	CALL	ISOVIEW			;TRANSFORM TO EUCLIDEAN COORDENATES
	LD	A,H			;ADD THE SCREEN OFFSET
	ADD	A,ISOX
	LD	D,A
	LD	A,L
	ADD	A,ISOY
	LD	E,A
	CALL	MARK			;MARK THE FLOOR
	POP	DE
	INC	D
	POP	BC
	DJNZ	S.LOOPX			;END OF X LOOP

	POP	DE
	INC	E
	POP	BC
	DJNZ	S.LOOPY			;END OF Y LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

ISOVIEW:LD	A,D
	SUB	E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,A			;X = (X-Y)*16

	LD	A,E
	ADD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	L,A			;Y = (X+Y)*8
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES OF THE MARK

	CSEG
	EXTRN	LINE

MARK:	LD	A,15
	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A

	PUSH	DE
	PUSH	DE
	PUSH	DE
	LD	C,E
	LD	A,D
	ADD	A,16
	LD	B,A
	CALL	LINE			;UPPER LINE

	POP	DE
	LD	A,E
	ADD	A,16
	LD	E,A
	LD	C,A
	LD	A,D
	ADD	A,16
	LD	B,A
	CALL	LINE			;LOWER LINE

	POP	DE
	LD	B,D
	LD	A,E
	ADD	A,16
	LD	C,A
	CALL	LINE			;LEFT LINE

	POP	DE
	LD	A,D
	ADD	A,16
	LD	D,A
	LD	B,A
	LD	A,E
	ADD	A,16
	LD	C,A
	JP	LINE			;RIGHT LINE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

POSEVENT:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
MAP:	DW	0
HEIGHT:	DB	0
ROOM:	DW	0
LEVEL:	DW	0


