
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
	EXTRN	GRID16

SHOWSCR:CALL	GRID16
	CALL	DRAWRMATRIX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDLEVEL,COLORGRID16

DRAWRMATRIX:
	LD	B,LVLYSIZ
	LD	DE,0

S.LOOPY:PUSH	BC
	PUSH	DE
	LD	B,LVLXSIZ

S.LOOPX:PUSH	BC
	PUSH	DE
	PUSH	DE
	LD	C,E
	LD	B,D
	LD	DE,(EDLEVEL)
	LD	L,0
	CALL	GETROOM
	POP	DE
	JR	Z,S.ENDX
	LD	A,(HL)
	INC	HL
	OR	(HL)
	CALL	Z,COLORGRID16

S.ENDX:	POP	DE
	INC	D
	POP	BC
	DJNZ	S.LOOPX

	POP	DE
	INC	E
	POP	BC
	DJNZ	S.LOOPY
	RET


