
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.ROOM
	EXTRN	CARTPAGE,EDINIT,LISTEN,VDPSYNC

ED.ROOM:CALL	EDINIT
	LD	E,LEVELPAGE
	CALL	CARTPAGE
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
	LD	DE,0

S.LOOPY:PUSH	BC
	PUSH	DE
	LD	B,LVLXSIZ

S.LOOPX:PUSH	BC
	PUSH	DE
	CALL	SHOWROOM
	POP	DE
	INC	D
	POP	BC
	DJNZ	S.LOOPX

	POP	DE
	INC	E
	POP	BC
	DJNZ	S.LOOPY
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDLEVEL,LMMV

SHOWROOM:
	PUSH	DE
	LD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,10H
	LD	D,A
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,10H
	LD	E,A
	LD	(S.LEVEL),DE
	CALL	MARK
	POP	DE

	LD	C,E
	LD	B,D
	LD	DE,(EDLEVEL)
	LD	L,0
	CALL	GETROOM
	RET	Z

	LD	A,(HL)
	INC	HL
	OR	(HL)
	RET	Z

	LD	DE,(S.LEVEL)
	INC	D
	INC	E
	LD	BC,0F0FH
	LD	A,15
	LD	(FORCLR),A
	JP	LMMV

	DSEG
S.LEVEL:DW	0


