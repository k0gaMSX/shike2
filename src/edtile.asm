
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.TILE
	EXTRN	CLRVPAGE,EDINIT,VDPSYNC,LISTEN

ED.TILE:CALL	EDINIT
	LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC

	LD	DE,RECEIVERS
	CALL	LISTEN
	RET

RECEIVERS:
	DB	1,253,0,254
	DW	TILEEVENT
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	SHOWSCR

SHOWSCR:LD	C,0
	LD	DE,6*8

S.LOOP:	PUSH	BC
	PUSH	DE
	CALL	DRAWTILE
	POP	DE
	LD	A,D
	ADD	A,32
	JR	NZ,S.1
	LD	A,E
	ADD	A,6*8
	LD	E,A
	XOR	A
S.1:	LD	D,A
	POP	BC
	LD	A,C
	INC	A
	LD	C,A
	CP	NR_TILES
	JR	NZ,S.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES
;	C = TILE NUMBER

	CSEG
	EXTRN	VDPPAGE,PNUM2XY,LMMM,MULTDEA

TILE.SIZ	EQU	12
NR_TILES	EQU	19

TILEDEF:DB	50,34,18,0,0,0,    51,35,19,0,0,0
	DB	1,66,34,18,0,0,    0,51,35,19,0,0
	DB	1,3,66,34,18,0,    0,0,51,35,19,0
	DB	1,3,3,66,34,18,    0,0,0,51,35,19

	DB	52,36,20,0,0,0,    53,37,21,0,0,0
	DB	0,52,36,20,0,0,    2,67,37,21,0,0
	DB	0,0,52,36,20,0,    2,4,67,37,21,0
	DB	0,0,0,52,36,20,    2,4,4,67,37,21

	DB	1,3,3,3,5,21,      0,0,0,0,0,0
	DB	1,3,3,3,5,22,      0,0,0,0,0,0
	DB	1,3,3,3,5,18,      0,0,0,0,0,0
	DB	7,8,8,8,9,18,      0,0,0,0,0,0

	DB	0,0,0,0,0,0,       2,4,4,4,6,18
	DB	0,0,0,0,0,0,       2,4,4,4,6,22
	DB	0,0,0,0,0,0,       2,4,4,4,6,21
	DB	0,0,0,0,0,0,       7,8,8,8,9,21

	DB	1,3,3,3,5,21,      2,4,4,4,6,18

	DB	7,8,8,8,9,22,      0,0,0,0,0,0
	DB	0,0,0,0,0,0,       7,8,8,8,9,22


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

	LD	B,2
T.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	DE

	LD	B,6
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
	EXTRN	EDTILE

TILEEVENT:
	CP	MS_BUTTON1
	RET	NZ
	LD	A,E
	SRL	A
	SRL	A
	SRL	A
	LD	E,0

T.LOOP:	SUB	6
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
	CP	NR_TILES
	RET	NC
	INC	A
	LD	(EDTILE),A
	RET



