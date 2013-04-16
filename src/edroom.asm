
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.ROOM
	EXTRN	EDINIT,LISTEN,VDPSYNC

ED.ROOM:CALL	EDINIT

	CALL	SHOWSCR
	CALL	VDPSYNC
	CALL	LISTEN
	JR	NZ,ED.ROOM
	RET


RECEIVERS:
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

SHOWSCR:CALL	RGRID
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	MARK

RGRID:	LD	B,LVLYSIZ
	LD	DE,1010H

S.LOOPY:PUSH	BC
	PUSH	DE
	LD	B,LVLXSIZ

S.LOOPX:PUSH	BC
	PUSH	DE
	CALL	MARK
	POP	DE
	LD	A,16
	ADD	A,D
	LD	D,A
	POP	BC
	DJNZ	S.LOOPX

	POP	DE
	LD	A,16
	ADD	A,E
	LD	E,A
	POP	BC
	DJNZ	S.LOOPY
	RET



