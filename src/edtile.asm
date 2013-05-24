
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
	LD	D,A
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
NR_TILES	EQU	2

TILEDEF:DB	50,34,18,0,0,0,51,35,19,0,0,0
	DB	52,36,20,0,0,0,53,37,21,0,0,0


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


