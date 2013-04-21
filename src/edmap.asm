
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
	LD	B,8

A.LOOPY:PUSH	BC			;RUN OVER Y
	PUSH	DE
	LD	B,8

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
	EXTRN	EDLEVEL,EDROOM,MAP

SHOWSCR:CALL	FGRID			;DRAW FLOOR GRID
	LD	DE,18
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

	XOR	A			;WE MAP ALWAYS AS HEIGHT 0
	LD	BC,0704H
	LD	DE,(MAPNO)
	CALL	MAP			;MAP THE FLOOR

	LD	A,(EDFLOOR)		;FLOOR 0 IS EMPTY TILE
	OR	A
	JR	Z,S.1
	LD	E,A
	CALL	GETFLOOR
	LD	E,FLOORYSIZ
	LD	BC,220*256 + 126
	CALL	DRAWSTACKS

S.1:	LD	A,(EDTILE)		;TILE 0 IS EMPTY TILE
	OR	A
	RET	Z
	LD	E,A
	CALL	GETTILE
	LD	DE,TILE.MAP
	ADD	HL,DE
	LD	E,TILEYSIZ
	LD	BC,220*256 + 150
	JP	DRAWSTACKS


FMT:	DB	" MAP",9," %04d",10
	DB	" HEIGHT",9,"   %02d",10
	DB	" ROOM",9,"%02dX%02d",10
	DB	" LEVEL",9,"%02dX%02d",10
	DB	" FLOOR",9,"  %03d",10
	DB	" TILE",9,"  %03d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
MAPG:	DB	3,  0, 142,   30,142,  0,  8,  0,  8
	DB	2,  0, 142,    0,158, 30,  0, 30,  0
	DB	2,220, 126,  236,126,  0, 16,  0, 16
	DB	2,220, 126,  220,142, 16,  0, 16,  0
	DB	2,220, 150,  236,150,  0, 48,  0, 48
	DB	2,220, 150,  220,198, 16,  0, 16,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	MARK

FGRID:	LD	DE,0
	LD	B,8

S.LOOPY:PUSH	BC			;LOOP OVER Y
	PUSH	DE
	LD	B,8

S.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	DE
	CALL	WRL2SCR			;TRANSFORM FROM WORLD TO SCREEN
	EX	DE,HL
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
;INPUT:	DE = SCREEN COORDINATES
;OUTPUT:HL = WORLD COORDENATES

	CSEG

ISOX	EQU	112
ISOY	EQU	32

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
	EXTRN	EDROOM,ADDAHL,EDTILE,EDFLOOR,GETTMAP,GETFMAP

POSEVENT:
	EX	AF,AF'
	LD	HL,(MAPNO)		;MAP 0 IS THE EMPTY MAP
	LD	A,L
	OR	H			;DON'T LET TO THE USER MODIFY IT
	RET	Z
	EX	AF,AF'

	PUSH	AF
	CALL	SCR2WRL			;TRANSFORM TO WORLD COORDENATES
	LD	A,L
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,H
	LD	(P.OFFSET),A		;CALCULATE OFFSET IN THE MAP
	POP	AF
	CP	MS_BUTTON1
	LD	DE,(MAPNO)
	JR	NZ,P.TILE

	CALL	GETFMAP			;BUTTON 1 SET FLOOR
	LD	A,(P.OFFSET)
	CALL	ADDAHL
	LD	A,(EDFLOOR)
	LD	(HL),A
	RET

P.TILE:	CALL	GETTMAP			;BUTTON 2 SET TILE
	LD	A,(P.OFFSET)
	CALL	ADDAHL
	LD	A,(EDTILE)
	LD	(HL),A
	RET

	DSEG
P.OFFSET:	DB	0

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

R.1:	LD	A,E			;RIGTH BUTTON DECREMENT ROOM NUMBER
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
	LD	A,(HEIGHT)
	JR	NZ,H.1
	CP	NR_HEIGHTS-1
	RET	Z
	INC	A
	JR	H.RET

H.1:	OR	A
	RET	Z
	DEC	A
H.RET:	LD	(HEIGHT),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ED.FLOOR,EDINIT

FLOOREVENT:
	CALL	ED.FLOOR
	JP	EDINIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ED.TILE,EDINIT

TILEEVENT:
	CALL	ED.TILE
	JP	EDINIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
MAPNO:	DW	0
HEIGHT:	DB	0
RPTR:	DW	0

