
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

NR_TILES	EQU	26
NR_TILES_ROW	EQU	3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.TILE
	EXTRN	CLRVPAGE,EDINIT,VDPSYNC,LISTEN

ED.TILE:CALL	EDINIT
	XOR	A
	LD	(QUIT),A

E.LOOP:	LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	RET	Z
	LD	A,(QUIT)
	OR	A
	JR	Z,E.LOOP

	RET

RECEIVERS:
	DB	1,29,182,8
	DW	PAGEEV
	DB	1,29,190,8
	DW	QUITEV
	DB	1,253,0,254
	DW	TILEEVENT
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SHOWSCR
	EXTRN	GLINES,LOCATE,PUTS,MULTEA

	EXTRN	PRINTF

SHOWSCR:LD	DE,23
	CALL	LOCATE
	LD	HL,(PAGE)
	LD	H,0
	PUSH	HL
	LD	DE,STR
	CALL	PRINTF

	LD	DE,MAPG
	LD	C,15
	CALL	GLINES			;DRAW BUTTONS

	LD	A,(PAGE)
	LD	E,NR_TILES_ROW*8
	CALL	MULTEA
	LD	C,L
	LD	DE,TILEYSIZ*8

S.LOOP:	PUSH	BC
	PUSH	DE
	CALL	DRAWTILE
	POP	DE
	LD	A,D
	ADD	A,TILEXSIZ*16
	JR	NZ,S.1
	LD	A,E
	ADD	A,TILEYSIZ*8
	LD	E,A
	XOR	A
S.1:	LD	D,A
	POP	BC
	LD	A,C
	INC	A
	LD	C,A
	CP	NR_TILES
	RET	Z
	CP	NR_TILES_ROW*8
	JR	NZ,S.LOOP

	RET

STR:	DB	" PAGE %d",10," QUIT",0

;	       REP  X0  Y0    X1  Y1  IX0 IY0 IX1 IY1
MAPG:	DB	3,  0,  182,  30,182,  0,  8,  0,  8
	DB	2,  0,  182,   0,198, 30,  0, 30,  0
	DB	4,  0,  8,   255,  8,  0, 56,  0, 56
	DB	9,  0,  8,     0,176, 32,  0, 32,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES
;	C = TILE NUMBER

	CSEG
	EXTRN	VDPPAGE,PNUM2XY,LMMM,MULTDEA,TILEDEF

DRAWTILE:
	LD	A,LOGTIMP
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A

	PUSH	DE
	LD	A,C
	LD	DE,TILE.SIZ
	CALL	MULTDEA
	LD	DE,TILEDEF
	ADD	HL,DE
	LD	(DT.PTR),HL
	POP	DE

	LD	B,TILEXSIZ
T.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	DE

	LD	B,TILEYSIZ
T.LOOPY:PUSH	BC			;LOOP OVER Y
	PUSH	DE

	PUSH	DE
	LD	HL,(DT.PTR)		;TAKE THE PATTERN NUMBER
	LD	E,(HL)
	INC	HL
	LD	(DT.PTR),HL
	CALL	PNUM2XY			;CONVERT IT TO COORDENATES
	POP	DE
	LD	BC,1008H
	CALL	LMMM			;COPY
	POP	DE
	LD	A,E
	SUB	8
	LD	E,A
	POP	BC
	DJNZ	T.LOOPY

	POP	DE
	LD	A,D
	ADD	A,16
	LD	D,A
	POP	BC
	DJNZ	T.LOOPX
	RET

	DSEG
DT.PTR:	DW	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG
	EXTRN	EDTILE,MULTEA

TILEEVENT:
	CP	MS_BUTTON1
	RET	NZ
	LD	A,E
	SRL	A
	SRL	A
	SRL	A
	LD	E,0

T.LOOP:	SUB	TILEYSIZ
	JR	C,T.BIG
	INC	E
	JR	T.LOOP

T.BIG:	LD	A,E
	RLCA
	RLCA
	RLCA
	LD	E,A
	LD	A,D
	AND	0E0H
	RRCA
	RRCA
	RRCA
	RRCA
	RRCA
	ADD	A,E
	PUSH	AF
	LD	A,(PAGE)
	LD	E,NR_TILES_ROW*8
	CALL	MULTEA
	POP	AF
	ADD	A,L
	CP	NR_TILES
	RET	NC
	INC	A
	LD	(EDTILE),A
	LD	A,1
	LD	(QUIT),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG

PAGEEV:	CP	MS_BUTTON2
	JR	Z,PREV
	CP	MS_BUTTON1
	RET	NZ
NEXT:	LD	A,(PAGE)
	CP	NR_TILES/(NR_TILES_ROW*8)
	RET	Z
	INC	A
	LD	(PAGE),A
	RET

PREV:	LD	A,(PAGE)
	OR	A
	RET	Z
	DEC	A
	LD	(PAGE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG

QUITEV:	LD	A,1
	LD	(QUIT),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
PAGE:	DB	0
QUIT:	DB	0

