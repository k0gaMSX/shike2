
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.LEVEL
	EXTRN	ADDGLISTEN,CARTPAGE,EDINIT,LISTEN,VDPSYNC

ED.LEVEL:
	CALL	EDINIT
	LD	DE,RECEIVERS
	LD	BC,POSEVENT
	CALL	ADDGLISTEN

ED.LOOP:LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LEVEL
	RET


RECEIVERS:
	DS	64*6
	DB	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GRID16

SHOWSCR:CALL	GRID16
	CALL	DRAWLMATRIX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	COLORGRID16

DRAWLMATRIX:
	LD	B,LVLYSIZ
	LD	DE,0

S.LOOPY:PUSH	BC
	PUSH	DE
	LD	B,LVLXSIZ

S.LOOPX:PUSH	BC
	PUSH	DE
	PUSH	DE
	CALL	GETLEVEL
	POP	DE
	CALL	NZ,COLORGRID16

S.ENDX:	POP	DE
	INC	D
	POP	BC
	DJNZ	S.LOOPX

	POP	DE
	INC	E
	POP	BC
	DJNZ	S.LOOPY
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

POSEVENT:
	RET

