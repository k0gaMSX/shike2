
	INCLUDE	SHIKE2.INC
	INCLUDE	DATA.INC
	INCLUDE	LEVEL.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL
;	BC = ROOM
;	HL = COORDENATES
;	A = HEIGHT

	CSEG
	PUBLIC	ED.OBJECT
	EXTRN	EDINIT,CLRVPAGE,PUTLPAGE,VDPSYNC,LISTEN

ED.OBJECT:
	LD	(POINT1+POINT.LEVEL),DE
	LD	(POINT1+POINT.ROOM),BC
	LD	(POINT1+POINT.Y),HL
	LD	(POINT1+POINT.Z),A
	CALL	EDINIT

ED.LOOP:LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	PUTLPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

RECEIVERS:
	DB	1,29,8,8
	DW	OBJEVENT
	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	LOCATE,GETNOBJ,PRINTF,GLINES

SHOWSCR:LD	DE,1
	CALL	LOCATE
	LD	DE,(NOBJ)
	CALL	GETNOBJ			;TAKE POINTERT TO THE OBJECT
	LD	(OBJPTR),HL
	PUSH	HL
	POP	IY

	LD	H,0
	LD	L,(IY+MOV.Z)
	PUSH	HL
	LD	L,(IY+MOV.Y)
	PUSH	HL
	LD	L,(IY+MOV.X)
	PUSH	HL
	LD	L,(IY+MOV.ROOM)
	PUSH	HL
	LD	L,(IY+MOV.ROOM+1)
	PUSH	HL
	LD	L,(IY+MOV.LEVEL)
	PUSH	HL
	LD	L,(IY+MOV.LEVEL+1)
	PUSH	HL
	LD	L,(IY+OBJECT.OWNER)
	PUSH	HL
	LD	L,(IY+OBJECT.ID)
	PUSH	HL
	LD	A,(NOBJ)
	LD	L,A
	PUSH	HL
	LD	DE,OINFO
	CALL	PRINTF			;PRINT INFORMATION

	LD	C,15
	LD	DE,OBJG
	CALL	GLINES			;DRAW BUTTONS
	RET


;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
OBJG:	DB	6,   0,  7,   30,  7,  0,  8,  0,  8
	DB	2,   0,  7,    0, 47, 30,  0, 30,  0
	DB	0


OINFO:	DB	" OBJECT",9,"%d",10
	DB	" ID ",9,"%d",10
	DB	" OWNER",9,"%d",10
	DB	" PLACE",10," SAVE",10
	DB	" LEVEL",9,"%02dX%02d",10
	DB	" ROOM",9,"%02dX%02d",10
	DB	" X",9,"%02d",10
	DB	" Y",9,"%02d",10
	DB	" Z",9,"%02d",0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG

OBJEVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENTS OBJ NUMBER
	JR	NZ,O.1
	LD	A,(NOBJ)
	CP	NR_OBJECTS-1
	RET	Z
	INC	A
	JR	O.END

O.1:	CP	MS_BUTTON2		;BUTTON 2 DECREMENTS OBJ NUMBER
	RET	NZ
	LD	A,(NOBJ)
	OR	A
	RET	Z
	DEC	A

O.END:	LD	(NOBJ),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	DSEG
NOBJ:	DB	0
OBJPTR:	DW	0
POINT1:	DS	SIZPOINT

