
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.MAP
	EXTRN	CLRVPAGE,CARTPAGE,EDINIT,VDPSYNC,LISTEN

ED.MAP:	CALL	EDINIT
	CALL	ADDRECEIVERS
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

	EXTRN	PALEVENT,SETEVENT

RECEIVERS:
	DB	1,29,142,8
	DW	ROOMEVENT
	DB	1,29,150,8
	DW	HEIGHTEVENT
	DB	220,16,126,16
	DW	FLOOREVENT
	DB	220,16,150,48
	DW	TILEEVENT
R.FLOOR:DS	64*6
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

ADDRECEIVERS:
	LD	HL,R.FLOOR
	LD	(A.PTR),HL
	LD	DE,0
	LD	B,MAPYSIZ

A.LOOPY:PUSH	BC			;RUN OVER Y
	PUSH	DE
	LD	B,MAPXSIZ

A.LOOPX:PUSH	BC			;RUN OVER X
	PUSH	DE
	CALL	WRL2SCR			;TRANSFORM TO SCREEN COORDENATES
	EX	DE,HL
	LD	HL,(A.PTR)
	INC	D			;AVOID X = 0
	LD	(HL),D
	INC	HL
	LD	(HL),15
	INC	HL
	LD	(HL),E
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
	EXTRN	DRAWSTACKS,EDTILE,EDFLOOR,GLINES,LOCATE,PRINTF
	EXTRN	EDLEVEL,EDROOM,MAPMAP

SHOWSCR:LD	DE,18
	CALL	LOCATE

	LD	H,0
	LD	A,(EDTILE)
	LD	L,A
	PUSH	HL
	LD	A,(EDFLOOR)
	LD	L,A
	PUSH	HL
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
	LD	A,(HEIGHT)
	LD	L,A
	PUSH	HL
	LD	DE,(MAPNO)
	PUSH	DE
	LD	DE,FMT
	CALL	PRINTF			;PRINT INFORMATION

	LD	DE,MAPG
	LD	C,15
	CALL	GLINES			;DRAW BUTTONS
	RET


FMT:	DB	" MAP",9," %04d",10
	DB	" HEIGHT",9,"   %02d",9,"POS %d,%d",10
	DB	" ROOM",9,"%02dX%02d",10
	DB	" LEVEL",9,"%02dX%02d",10
	DB	" FLOOR",9,"  %03d",10
	DB	" TILE",9,"  %03d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
MAPG:	DB     	9,  0,  95,  127, 32, 16,  8, 16,  8
	DB	9,  0,  96,  127,159, 16, -8, 16, -8
	DB	3,  0, 142,   30,142,  0,  8,  0,  8
	DB	2,  0, 142,    0,158, 30,  0, 30,  0
	DB	2,220, 126,  236,126,  0, 16,  0, 16
	DB	2,220, 126,  220,142, 16,  0, 16,  0
	DB	2,220, 150,  236,150,  0, 48,  0, 48
	DB	2,220, 150,  220,198, 16,  0, 16,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDINATES
;OUTPUT:HL = WORLD COORDENATES

	CSEG

ISOX	EQU	CENTRAL.P1X*16
ISOY	EQU	CENTRAL.P1Y*8

SCR2WRL:SRL	E
	SRL	E
	SRL	E			;E = Ys/8
	LD	A,E
	SUB	ISOY/8
	LD	E,A			;E = Y' = (Ys - ISOY)/8
	SLA	E
	SLA	E			;E = 4Y'
	SRL	D
	SRL	D
	SRL	D			;D = Xs/8
	LD	A,D
	AND	0FEH			;CLEAN LOWER BIT, BECAUSE WE WANT
	SUB	ISOX/8			;LEFT UP CORNERS
	LD	D,A			;D = X' = (Xs - ISOX)/8
	SLA	D			;D = 2X'

	LD	A,E
	ADD	A,D			;A = 4Y' + 2X'
	SRA	A
	SRA	A
	SRA	A
	LD	H,A			;H = Xw = (4Y' + 2X')/8

	LD	A,E
	SUB	D			;A = 4Y' - 2X'
	SRA	A
	SRA	A
	SRA	A
	LD	L,A			;L = Yw = (4Y' - 2X')/8
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = WORLD COORDENATES
;OUTPUT:HL = SCREEN COORDENATES
	CSEG

WRL2SCR:LD	A,D
	SUB	E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A			;X' = (Xw-Yw)*16
	ADD	A,ISOX
	LD	H,A			;Xs = X' + ISOX

	LD	A,E
	ADD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A			;Y' = (Xw+Yw)*8
	ADD	A,ISOY
	LD	L,A			;Ys = Y' + ISOY
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = PARAMETER (IN MOUSE EVENTS = SCREEN COORDENATES)

	CSEG
	EXTRN	EDROOM,ADDAHL,EDTILE,EDFLOOR,GETTMAP,GETFMAP,GETHMAP

POSEVENT:
	EX	AF,AF'
	LD	HL,(MAPNO)		;MAP 0 IS THE EMPTY MAP
	LD	A,L
	OR	H			;DON'T LET TO THE USER MODIFY IT
	RET	Z
	EX	AF,AF'

	PUSH	AF
	CALL	SCR2WRL			;TRANSFORM TO WORLD COORDENATES
	LD	(P.COORD),HL
	LD	A,L
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,H
	LD	(P.OFFSET),A		;CALCULATE OFFSET IN THE MAP
	POP	AF
	CP	MS_BUTTON1
	JR	NZ,P.TILE

	LD	DE,(MAPNO)
	CALL	GETFMAP			;BUTTON 1 SET FLOOR
	LD	A,(P.OFFSET)
	CALL	ADDAHL
	LD	A,(EDFLOOR)
	LD	(HL),A
	RET

P.TILE:	CP	MS_BUTTON2		;BUTTON 2 SET TILE
	JR	NZ,P.INFO

	LD	DE,(EDTILE)		;GET THE HEIGHT OF THE TILE
	CALL	GETTILE
	EX	DE,HL
	LD	IYL,E
	LD	IYU,D
	LD	A,(IY+TILE.HEIGHT)
	PUSH	AF
	LD	DE,(MAPNO)
	CALL	GETHMAP			;GET THE HEIGHT MAP
	LD	A,(P.OFFSET)
	CALL	ADDAHL
	POP	AF
	LD	(HL),A

	LD	DE,(MAPNO)
	CALL	GETTMAP			;BUTTON 2 SET TILE
	LD	A,(P.OFFSET)
	CALL	ADDAHL
	LD	A,(EDTILE)
	LD	(HL),A
	RET

P.INFO:	CP	KB_F1
	RET	NZ
	LD	HL,(P.COORD)
	LD	(COORD),HL
	RET

	DSEG
P.OFFSET:	DB	0
P.COORD:	DW	0

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

	CSEG
	EXTRN	EDINIT

FLOOREVENT:
	JP	EDINIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDINIT

TILEEVENT:
	JP	EDINIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
COORD:	DW	0
MAPNO:	DW	0
HEIGHT:	DB	0
RPTR:	DW	0

