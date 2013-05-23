
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	RET

RECEIVERS:
	DB	1,32*NR_FLOORS,0,16
	DW	FLOOREVENT
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	DRAWFLOOR

SHOWSCR:LD	C,0
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG
	EXTRN	EDFLOOR

FLOOREVENT:
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
	LD	(EDFLOOR),A
	RET



