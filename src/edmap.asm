
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC
	INCLUDE SPRITE.INC

POINTCOL	EQU	15

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.MAP
	EXTRN	SPRITE,SETCOLSPR,CLRVPAGE,CARTPAGE,EDINIT,VDPSYNC,LISTEN

ED.MAP:	CALL	EDINIT
	LD	C,POINTPAT
	LD	DE,PATDATA
	LD	B,4
	CALL	SPRITE

	LD	C,POINTSPR
	LD	E,POINTCOL
	LD	B,1
	CALL	SETCOLSPR

	LD	HL,0
	LD	(COORD),HL

ED.LOOP:LD	E,EDPAGE
	CALL	CLRVPAGE
	LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	GETMDATA
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

PATDATA:DB	010H,030H,070H,0FFH,0FFH,070H,030H,010H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

RECEIVERS:
	DB	1,29,166,8
	DW	ROOMEVENT
	DB	54,30,166,8
	DW	FLOOREVENT
	DB	1,29,174,8
	DW	HEIGHTEVENT
	DB	54,30,174,8
	DW	TILEEVENT
	DB	1,254,32,127
	DW	MAPEVENT
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDLEVEL,EDROOM,MULTDEA,PTRHL

GETMDATA:				;UPDATE THE MAP VARIABLES
	LD	HL,0
	LD	(RPTR),HL
	LD	(MAPNO),HL

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	A,(HEIGHT)
	CALL	GETROOM
	RET	Z
	LD	(RPTR),HL
	CALL	PTRHL
	LD	(MAPNO),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	PUTSPRITE,DRAWSTACKS,EDTILE,EDFLOOR,GLINES,LOCATE,PRINTF
	EXTRN	EDLEVEL,EDROOM,MAPMAP,ZVALINIT

SHOWSCR:LD	DE,21
	CALL	LOCATE

	LD	H,0
	LD	DE,(EDLEVEL)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	DE,(EDROOM)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	DE,(COORD)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	A,(EDTILE)
	LD	L,A
	PUSH	HL
	LD	A,(HEIGHT)
	LD	L,A
	PUSH	HL
	LD	A,(EDFLOOR)
	LD	L,A
	PUSH	HL
	LD	DE,(MAPNO)
	PUSH	DE
	LD	DE,FMT
	CALL	PRINTF			;PRINT INFORMATION

	CALL	ZVALINIT
	XOR	A			;WE MAP ALWAYS AS HEIGHT 0
	LD	BC,MAP.CENTRAL
	LD	DE,(MAPNO)
	CALL	MAPMAP			;MAP THE FLOOR

	LD	DE,MAPG
	LD	C,15
	CALL	GLINES			;DRAW BUTTONS

	LD	D,120
	LD	A,(ACTION)
	RLCA
	RLCA
	RLCA
	ADD	A,168
	LD	E,A
	LD	B,POINTPAT
	LD	C,POINTSPR
	JP	PUTSPRITE		;SHOW THE SELECTED ACTION


FMT:	DB	" MAP",9," %04d FLOOR",9,"%03d",10
	DB	" HEIGHT",9,"   %02d TILE",9,"%03d",10
	DB	" POS=%03dX%03d,ROOM=%02dX%02d,LEVEL=%02dX%02d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
MAPG:	DB     	9,  0,   95, 127, 32, 16,  8, 16,  8
	DB	9,  0,   96, 127,159, 16, -8, 16, -8
	DB	3,  0,  166,  30,166,  0,  8,  0,  8
	DB	2,  0,  166,   0,182, 30,  0, 30,  0
	DB	3,  54, 166,  84,166,  0,  8,  0,  8
	DB	2,  54, 166,  54,182, 30,  0, 30,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDINATES
;OUTPUT:HL = COORDENATES


ISOX	EQU	128
ISOY	EQU	32

	CSEG

SCR2WRL:LD	C,E
	LD	B,D

	LD	L,B
	LD	H,0			;HL = X
	LD	DE,ISOX
	OR	A
	SBC	HL,DE			;HL = X' = X - ISOX
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			;HL = 16X'
	PUSH	HL
	PUSH	HL

	LD	L,C
	LD	H,0			;HL = Y
	LD	DE,ISOY
	OR	A
	SBC	HL,DE			;HL = Y' = Y - ISOY
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			;HL = 32Y'
	POP	DE			;DE = 16X'
	PUSH	HL

	OR	A
	SBC	HL,DE			;HL = 32Y' - 16X'
	LD	A,H

	POP	HL			;HL = Y'
	POP	DE			;DE = X'
	ADD	HL,DE			;HL = 32Y' + 16X'
	SRL	H			;H = (32Y' + 16X')/(32*16)
	LD	L,A
	SRL	L			;L = (32Y' - 16X')/(32*16)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

ROOMEVENT:
	CP	MS_BUTTON1		;LEFT BUTTON INCREMENT ROOM NUMBER
	LD	DE,(MAPNO)
	JR	NZ,R.1
	LD	HL,NR_MAPS
	CALL	DCOMPR
	RET	Z
	INC	DE
	JR	R.RET

R.1:	CP	MS_BUTTON2
	RET	NZ
	LD	A,E			;RIGTH BUTTON DECREMENT ROOM NUMBER
	OR	D
	RET	Z
	DEC	DE
R.RET:	LD	(MAPNO),DE		;UPDATE MAP NUMBER
	LD	HL,(RPTR)
	LD	(HL),E			;UPDATE THE ROOM MATRIX
	INC	HL
	LD	(HL),D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

HEIGHTEVENT:
	CP	MS_BUTTON1
	JR	NZ,H.1
	LD	A,(HEIGHT)
	CP	NR_HEIGHTS-1
	RET	Z
	INC	A
	JR	H.RET

H.1:	CP	MS_BUTTON2
	RET	NZ
	LD	A,(HEIGHT)
	OR	A
	RET	Z
	DEC	A
H.RET:	LD	(HEIGHT),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG
	EXTRN	ED.FLOOR

FLOOREVENT:
	CP	KB_SPACE
	JR	NZ,F.1
	XOR	A
	LD	(ACTION),A
	RET
F.1:	CP	MS_BUTTON1
	CALL	Z,ED.FLOOR
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG
	EXTRN	ED.TILE

TILEEVENT:
	CP	KB_SPACE
	JR	NZ,T.1
	LD	A,1
	LD	(ACTION),A
	RET
T.1:	CP	MS_BUTTON1
	CALL	Z,ED.TILE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT
;	HL = SCREEN COORDINATES

	CSEG
	EXTRN	EDFLOOR,GETFMAP,ADDAHL,GETTMAP

MAPEVENT:
	LD	(M.EV),A
	LD	HL,(MAPNO)
	LD	A,L
	OR	H
	RET	Z			;MAP 0 MEANS NO MAP

	CALL	SCR2WRL			;TRANSFORM SCREEN COORDENATES
	LD	A,H			;TO MAP COORDENATES
	BIT	7,A
	RET	NZ
	CP	LVLXSIZ			;CHECK IF THE COORDENATES ARE IN
	RET	NC			;THE CORRECT RANGE
	LD	A,L
	BIT	7,A
	RET	NZ
	CP	LVLYSIZ
	RET	NC
	LD	(M.COOR),HL
	LD	A,L
	RLCA
	RLCA
	RLCA
	ADD	A,H
	LD	(M.OFFSET),A		;OFFSET IN THE MAP

	LD	A,(M.EV)
	CP	KB_F1
	JR	Z,M.INFO
	LD	A,(ACTION)
	OR	A
	JR	NZ,M.TILE

M.FLOOR:LD	DE,(MAPNO)		;GET THE ADDRESS OF THE MAP
	CALL	GETFMAP
	LD	A,(M.OFFSET)
	CALL	ADDAHL

	LD	A,(M.EV)
	CP	MS_BUTTON2
	LD	A,(EDFLOOR)		;BUTTON 1 SETS THE FLOOR
	JR	NZ,M.1			;BUTTON 2 RESETS THE FLOOR
	XOR	A
M.1:	LD	(HL),A
	RET

	PUBLIC	M.TILE
M.TILE:	LD	DE,(MAPNO)		;GET THE ADDRESS OF THE MAP
	CALL	GETTMAP
	LD	A,(M.OFFSET)
	CALL	ADDAHL

	LD	A,(M.EV)
	CP	MS_BUTTON2
	LD	A,(EDTILE)		;BUTTON 1 SETS THE FLOOR
	JR	NZ,M.2			;BUTTON 2 RESETS THE FLOOR
	XOR	A
M.2:	LD	(HL),A
	RET

M.INFO:	LD	HL,(M.COOR)
	LD	(COORD),HL
	RET

	DSEG
M.EV:		DB	0
M.COOR:		DW	0
M.OFFSET:	DB	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
ACTION:	DB	0
COORD:	DW	0
MAPNO:	DW	0
HEIGHT:	DB	0
RPTR:	DW	0

