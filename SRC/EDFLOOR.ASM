
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

NR_FLOORS	EQU	8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:Z = 1 WHEN NO FLOOR IS SELECTED
;	A = FLOOR NUMBER WHEN Z = 0

	CSEG
	PUBLIC	ED.FLOOR
	EXTRN	CLRVPAGE,EDINIT,VDPSYNC,LISTEN

ED.FLOOR:
	CALL	EDINIT
	LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC

	LD	DE,RECEIVERS
	CALL	LISTEN
	LD	A,(FLOOR)
	RET

RECEIVERS:
	DB	1,253,0,16
	DW	FLOOREVENT
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GLINES

SHOWSCR:LD	DE,MAPG
	LD	C,15
	CALL	GLINES			;DRAW BUTTONS

	LD	C,0
	LD	DE,0

S.LOOP:	PUSH	DE			;DRAW ALL THE FLOORS
	PUSH	BC
	CALL	DRAWFLOOR
	POP	BC
	POP	DE
	LD	A,D
	ADD	A,32
	LD	D,A
	LD	A,C
	INC	A
	LD	C,A
	CP	NR_FLOORS
	JR	NZ,S.LOOP
	RET


;	       REP  X0  Y0    X1  Y1  IX0 IY0 IX1 IY1
MAPG:	DB	1,  0,  16,  255, 16,  0, 16,  0, 16
	DB	9,  0,  0,     0, 16, 32,  0, 32, 0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES
;	C = FLOOR NUMBER


	CSEG
	PUBLIC	DRAWFLOOR
	EXTRN	LMMM,VDPPAGE,PNUM2XY,FLOORDEF

DRAWFLOOR:
	LD	A,C
	RLCA
	RLCA
	LD	C,A
	LD	B,0
	LD	HL,FLOORDEF
	ADD	HL,BC
	LD	(D.PTR),HL
	LD	(D.COORD),DE
	LD	A,LOGTIMP
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A

	LD	E,(HL)
	INC	HL
	LD	(D.PTR),HL
	CALL	PNUM2XY
	LD	DE,(D.COORD)
	LD	BC,1008H
	CALL	LMMM			;DRAW LEFT-UP PATTERN

	LD	HL,(D.PTR)
	LD	E,(HL)
	INC	HL
	LD	(D.PTR),HL
	CALL	PNUM2XY
	LD	DE,(D.COORD)
	LD	A,D
	ADD	A,16
	LD	D,A
	LD	BC,1008H
	CALL	LMMM			;DRAW RIGHT-UP PATTERN

	LD	HL,(D.PTR)
	LD	E,(HL)
	INC	HL
	LD	(D.PTR),HL
	CALL	PNUM2XY
	LD	DE,(D.COORD)
	LD	A,E
	ADD	A,8
	LD	E,A
	LD	BC,1008H
	CALL	LMMM			;DRAW LEFT-DOWN PATTERN

	LD	HL,(D.PTR)
	LD	E,(HL)
	CALL	PNUM2XY
	LD	DE,(D.COORD)
	LD	A,D
	ADD	A,16
	LD	D,A
	LD	A,E
	ADD	A,8
	LD	E,A
	LD	BC,1008H
	JP	LMMM			;DRAW RIGHT-DOWN PATTERN

	DSEG
D.PTR:	DW	0
D.COORD:DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG

FLOOREVENT:
	CP	MS_BUTTON1
	RET	NZ
	LD	A,D
	AND	0E0H
	RRCA
	RRCA
	RRCA
	RRCA
	RRCA
	CP	NR_FLOORS
	RET	NC
	INC	A
	LD	(FLOOR),A
	RET


	DSEG
FLOOR:	DB	0

