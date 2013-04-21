
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.ROOM
	EXTRN	ADDGLISTEN,CARTPAGE,EDINIT,LISTEN,VDPSYNC

ED.ROOM:CALL	EDINIT
	LD	DE,R.PTR
	LD	BC,POSEVENT
	CALL	ADDGLISTEN

ED.LOOP:LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	GETRDATA
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET


RECEIVERS:
	DB	156,30,158,8
	DW	LEVELPAL
	DB	156,30,166,8
	DW	LEVELSET
R.PTR:	DS	64*6
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDSET,EDPAL,EDLEVEL

GETRDATA:
	LD	DE,(EDLEVEL)
	CALL	GETLEVEL
	RET	Z
	PUSH	HL
	POP	IY
	LD	A,(IY+LVL.PAL)
	LD	(EDPAL),A
	LD	A,(IY+LVL.GFX)
	LD	(EDSET),A
	LD	(LPTR),IY
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GLINES,EDPAL,EDSET,PTRHL,PRINTF,LOCATE,EDLEVEL,GRID16

SHOWSCR:CALL	GRID16
	CALL	DRAWRMATRIX

	LD	DE,0
	CALL	LOCATE
	LD	HL,(LPTR)
	PUSH	HL
	LD	DE,TITLE
	CALL	PRINTF

	LD	DE,0054H
	CALL	LOCATE

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	A,2
	CALL	GETROOM
	CALL	PTRHL
	PUSH	HL

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	A,1
	CALL	GETROOM
	CALL	PTRHL
	PUSH	HL

	LD	HL,(EDSET)
	LD	H,0
	PUSH	HL

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	XOR	A
	CALL	GETROOM
	CALL	PTRHL
	PUSH	HL

	LD	HL,(EDPAL)
	LD	H,0
	PUSH	HL

	LD	H,0
	LD	DE,(EDROOM)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	DE,ROOMI
	CALL	PRINTF

	LD	C,15
	LD	DE,ROOMG
	JP	GLINES


;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
ROOMG:	DB	3, 156,158,  186,158,  0,  8,  0,  8
	DB	2, 156,158,  156,174, 30,  0, 30,  0
	DB	0

TITLE:	DB	9,"ROOM EDITOR: LEVEL %s",0
ROOMI:	DB	9,"ROOM",9,"     %03dX%03d",9,9,"PALETE",9,"%d",10
	DB	9,"HEIGHT 0",9,"%04d",9,9,"SET",9,"%d",10
	DB	9,"HEIGHT 1",9,"%04d",10
	DB	9,"HEIGHT 2",9,"%04d",0

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
	LD	A,0
	CALL	GETROOM
	POP	DE
	JR	Z,S.ENDX
	LD	A,(HL)
	INC	HL
	OR	(HL)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN POSITION

	CSEG
	EXTRN	EDROOM,ED.MAP,GRIDPOS

POSEVENT:
	PUSH	AF
	CALL	GRIDPOS
	POP	AF
	CP	MS_BUTTON1
	JR	NZ,P.1
	LD	(EDROOM),DE
	CALL	ED.MAP
	JP	EDINIT

P.1:	LD	(EDROOM),DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	PALEVENT,EDPAL

LEVELPAL:
	CALL	PALEVENT
	LD	IY,(LPTR)
	LD	A,(EDPAL)
	LD	(IY+LVL.PAL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SETEVENT,EDSET
	PUBLIC	LEVELSET

LEVELSET:
	CALL	SETEVENT
	LD	E,LEVELPAGE
	CALL	CARTPAGE
	LD	IY,(LPTR)
	LD	A,(EDSET)
	LD	(IY+LVL.GFX),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
LPTR:	DW	0


