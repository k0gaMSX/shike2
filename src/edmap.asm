
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDMAP
	EXTRN	CARTPAGE,EDINIT,VDPSYNC,LISTEN

EDMAP:	CALL	EDINIT


E.LOOP:	LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,E.LOOP
	RET


RECEIVERS:
	DB	1,29,142,8
	DW	CHANGEPAL
	DB	0




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SETPAL,GLINES,LOCATE,PRINTF

SHOWSCR:LD	DE,(PAL)
	CALL	GETPAL
	CALL	SETPAL			;LOAD THE SELECTED PALETE

	CALL	FGRID			;DRAW FLOOR GRID
	LD	DE,18
	CALL	LOCATE

	LD	H,0
	LD	A,(RLEVEL2)
	LD	L,A
	PUSH	HL
	LD	A,(RLEVEL1)
	LD	L,A
	PUSH	HL
	LD	A,(RLEVEL0)
	LD	L,A
	PUSH	HL
	LD	A,(ROOM)
	LD	L,A
	PUSH	HL
	LD	A,(LEVEL)
	LD	L,A
	PUSH	HL
	LD	A,(SET)
	LD	L,A
	PUSH	HL
	LD	A,(PAL)
	LD	L,A
	PUSH	HL
	LD	DE,FMT
	CALL	PRINTF			;PRINT INFORMATION

	LD	DE,MAPG
	LD	C,15
	CALL	GLINES
	RET

FMT:	DB	" PALETE",9,"%3d",10
	DB	" SET",9,"%3d",10
	DB	" LEVEL",9,"%3d",10
	DB	" ROOM",9,"%03d",10
	DB	" LEVEL0:%03d",10
	DB	" LEVEL1:%03d",10
	DB	" LEVEL2:%03d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
MAPG:	DB	5,  0, 142,   30,142,  0,  8,  0,  8
	DB	2,  0, 142,    0,174, 30,  0, 30,  0
	DB	2,220, 126,  236,126,  0, 16,  0, 16
	DB	2,220, 126,  220,142, 16,  0, 16,  0
	DB	2,220, 150,  236,150,  0, 48,  0, 48
	DB	2,220, 150,  220,198, 16,  0, 16,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

FGRID:	LD	DE,0
	LD	B,8

S.LOOPY:PUSH	BC			;LOOP OVER Y
	PUSH	DE
	LD	B,8

S.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	DE
	CALL	MFLOOR			;MARK THE FLOOR
	POP	DE
	INC	D
	POP	BC
	DJNZ	S.LOOPX			;END OF X LOOP

	POP	DE
	INC	E
	POP	BC
	DJNZ	S.LOOPY			;END OF Y LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = FLOOR POSITION

	CSEG
	EXTRN	LINE

MFLOOR:	LD	A,E			;CALCULATE THE ISOMETRIC COORDENATES
	SUB	D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,94
	LD	L,A			;Y = (Y-X)*8

	LD	A,D
	ADD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,A			;X = (Y+X)*16

	LD	A,15
	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A

	EX	DE,HL
	PUSH	DE
	PUSH	DE
	PUSH	DE
	LD	C,E
	LD	A,D
	ADD	A,16
	LD	B,A
	CALL	LINE			;UPPER LINE

	POP	DE
	LD	A,E
	ADD	A,16
	LD	E,A
	LD	C,A
	LD	A,D
	ADD	A,16
	LD	B,A
	CALL	LINE			;LOWER LINE

	POP	DE
	LD	B,D
	LD	A,E
	ADD	A,16
	LD	C,A
	CALL	LINE			;LEFT LINE

	POP	DE
	LD	A,D
	ADD	A,16
	LD	D,A
	LD	B,A
	LD	A,E
	ADD	A,16
	LD	C,A
	JP	LINE			;RIGHT LINE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG

CHANGEPAL:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENT PALETE NUMBER
	LD	A,(PAL)
	JR	NZ,P.DEC
	CP	NR_PALETES-1
	RET	Z
	INC	A
	JR	P.RET

P.DEC:	OR	A			;BUTTON 2 DECREMENT PALETE NUMBER
	RET	Z
	DEC	A
P.RET:	LD	(PAL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
ROOM:	DB	0
RLEVEL0:DB	0
RLEVEL1:DB	0
RLEVEL2:DB	0
LEVEL:	DB	0
SET:	DB	0
PAL:	DB	0


