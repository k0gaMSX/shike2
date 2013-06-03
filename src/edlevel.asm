
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDITOR
	EXTRN	ADDGLISTEN,CARTPAGE,EDINIT,LISTEN,VDPSYNC,EDRUN

EDITOR:	LD	A,1
	LD	(EDRUN),A
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
	JR	NZ,ED.LOOP
	XOR	A
	LD	(EDRUN),A
	RET


RECEIVERS:
	DS	64*6
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDLEVEL,PUTS,LOCATE,PRINTF,GRID16

SHOWSCR:CALL	GRID16
	CALL	DRAWLMATRIX

	LD	DE,0000H
	CALL	LOCATE
	LD	DE,LVLSTR
	CALL	PUTS

	LD	DE,0054H
	CALL	LOCATE
	LD	DE,(EDLEVEL)
	CALL	GETLEVEL
	RET	Z
	PUSH	HL
	POP	IY
	LD	H,0
	LD	L,(IY+LVL.GFX)
	PUSH	HL
	LD	L,(IY+LVL.PAL)
	PUSH	HL
	PUSH	IY
	LD	DE,FMT
	CALL	PRINTF
	RET

LVLSTR:	DB	9,"LEVEL EDITOR",10,0
FMT:	DB	9,"NAME:",9,"                   "
	DB	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,"%s",10
	DB	9,"PALETE",9,"%d",10
	DB	9,"SET",9,"%d",0

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
;INPUT:	A = EVENT
;	DE = SCREEN POSITION

	CSEG
	EXTRN	EDINIT,GRIDPOS,EDLEVEL,ED.ROOM

POSEVENT:
	PUSH	AF
	CALL	GRIDPOS
	POP	AF
	CP	MS_BUTTON1
	JR	NZ,P.1
	LD	(EDLEVEL),DE
	CALL	GETLEVEL
	RET	Z
	CALL	ED.ROOM
	JP	EDINIT

P.1:	CP	MS_BUTTON2
	RET	NZ
	LD	(EDLEVEL),DE
	RET

