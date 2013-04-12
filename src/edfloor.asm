
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDFLOOR
	EXTRN	EDINIT,MPRESS,VDPSYNC,CARTPAGE,LISTEN

EDFLOOR:CALL	EDINIT
	LD	A,(SET)
	LD	E,A
	CALL	LOADSET

ED.LOOP:LD	E,LEVELPAGE
	CALL	CARTPAGE
	CALL	GETFDATA
	CALL	SHOWSCR
	CALL	VDPSYNC
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

RECEIVERS:
	DB	80,30,30,8
	DW	CHANGEFLOOR
	DB	80,30,38,8
	DW	CHANGEPAL
	DB	80,30,46,8
	DW	CHANGESET
	DB	80,16,78,8
	DW	PUTPATTERN1
	DB	80,16,86,8
	DW	PUTPATTERN2
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = SET NUMBER

	CSEG
	EXTRN	VLDIR,CARTPAGE

LOADSET:LD	A,SET0PAGE
	ADD	A,E
	LD	E,A
	CALL	CARTPAGE
	LD	HL,CARTSEG
	LD	DE,00000H
	LD	BC,04000H
	LD	A,PATPAGE*2
	JP	VLDIR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

GETFDATA:
	LD	A,(FLOOR)
	LD	E,A
	CALL	GETFLOOR		;GET THE POINTER TO THE FLOOR

	PUSH	HL
	CALL	GETNUMPAT
	LD	(NUMPAT1),A
	POP	HL
	LD	DE,NR_LAYERS
	ADD	HL,DE
	CALL	GETNUMPAT
	LD	(NUMPAT2),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = POINTER TO THE FLOOR
;OUTPUT:A = NUMBER OF USED LAYERS IN THE PATTERN STACK

	CSEG

GETNUMPAT:
	XOR	A
	LD	BC,NR_LAYERS+1
	CPIR
	LD	A,NR_LAYERS
	SUB	C
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	SETPAL,LOCATE,PRINTF,GLINES

SHOWSCR:LD	DE,(PAL)
	CALL	GETPAL
	CALL	SETPAL
	LD	DE,0
	CALL	LOCATE
	LD	H,0
	LD	A,(NUMPAT2)
	LD	L,A
	PUSH	HL
	LD	A,(NUMPAT1)
	LD	L,A
	PUSH	HL
	LD	A,(SET)
	LD	L,A
	PUSH	HL
	LD	A,(PAL)
	LD	L,A
	PUSH	HL
	LD	A,(FLOOR)
	LD	L,A
	PUSH	HL
	LD	DE,FMT
	CALL	PRINTF
	LD	DE,FLOORG
	LD	C,15
	JP	GLINES

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
FLOORG:	DB	4,  80, 30,  110, 30,  0,  8,  0,  8
	DB	2,  80, 30,   80, 54, 30,  0, 30,  0
	DB	3,  80, 78,   96, 78,  0,  8,  0,  8
	DB	2,  80, 78,   80, 94, 16,  0, 16,  0
	DB	0

FMT:	DB	10,10,10,10
	DB	9,9,"     FLOOR",9,"%3d",10
	DB	9,9,"     PALETE",9,"%03d",10
	DB	9,9,"     SET",9,"%03d",10
	DB	10,10,10
	DB	9,9,9," %d",10
	DB	9,9,9," %d",0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = XY COORDENATES
;OUTPUT:A = PATTERN NUMBER

	CSEG

XY2PAT:	LD	A,E
	AND	078H
	RLCA
	PUSH	AF

	LD	A,D
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	POP	HL
	OR	H
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SETPAGE,PSELECT,SETPAGE

SELPAT:	LD	A,PATPAGE
	LD	(DPPAGE),A

	CALL	SETPAGE
	CALL	PSELECT
	CP	KB_ESC
	JR	NZ,S.1
	XOR	A
	JR	S.END

S.1:	CP	MS_BUTTON1
	JR	NZ,SELPAT
	BIT	7,H
	JR	NZ,SELPAT
	EX	DE,HL
	CALL	XY2PAT

S.END:	PUSH	AF
	LD	A,EDPAGE
	LD	(DPPAGE),A
	CALL	SETPAGE
	POP	AF
	OR	A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = LAYER
;	BC = COORDENATE OFFSET

	CSEG

DELLAYER:
	DEC	E
	LD	D,0
	;CONTINUE IN ADDLAYER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = LAYER
;	D = PATTERN
;	BC = COORDENATE OFFSET


	CSEG
	EXTRN	MULTDEA

ADDLAYER:
	PUSH	DE			;SAVE D = PATTERN NUMBER
	EX	DE,HL
	LD	H,0
	ADD	HL,BC			;HL = OFFSET
	PUSH	HL

	LD	DE,(FLOOR)
	CALL	GETFLOOR		;HL = FLOOR POINTER

	POP	DE
	ADD	HL,DE			;POINTERT TO PATTERN

	POP	DE			;D = PATTERN NUMBER
	LD	(HL),D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	(P.OFFSET) = COORDENATE OFFSET
;	(P.NUM) = NUMBERS OF TILES

	CSEG

PEVENT:	CP	MS_BUTTON1
	LD	A,(P.NUM)
	JR	NZ,P1.1

	CP	NR_LAYERS
	CALL	NZ,SELPAT
	LD	DE,(P.NUM)
	LD	D,A
	LD	BC,(P.OFFSET)
	CALL	NZ,ADDLAYER
	RET

P1.1:	OR	A
	LD	E,A
	LD	BC,(P.OFFSET)
	CALL	NZ,DELLAYER
	RET

	DSEG
P.NUM:		DB	0
P.OFFSET:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A = EVENT

	CSEG

PUTPATTERN1:
	PUSH	AF
	LD	A,(NUMPAT1)
	LD	(P.NUM),A
	LD	BC,0
	LD	(P.OFFSET),BC
	POP	AF
	JR	PEVENT

PUTPATTERN2:
	PUSH	AF
	LD	A,(NUMPAT2)
	LD	(P.NUM),A
	LD	BC,NR_LAYERS
	LD	(P.OFFSET),BC
	POP	AF
	JR	PEVENT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

CHANGEFLOOR:
	CP	MS_BUTTON1
	LD	A,(FLOOR)
	JR	NZ,F.DEC
	INC	A
	JR	F.RET

F.DEC:	DEC	A
F.RET:	LD	(FLOOR),A

	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG

CHANGEPAL:
	CP	MS_BUTTON1
	LD	A,(PAL)
	JR	NZ,P.DEC
	CP	NR_PALETES-1
	RET	Z
	INC	A
	JR	P.RET

P.DEC:	OR	A
	RET	Z
	DEC	A
P.RET:	LD	(PAL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CHANGESET:
	CP	MS_BUTTON1
	LD	A,(SET)
	JR	NZ,S.DEC
	CP	NR_PATSET-1
	RET	Z
	INC	A
	JR	S.RET

S.DEC:	OR	A
	RET	Z
	DEC	A
S.RET:	LD	(SET),A
	LD	E,A
	JP	LOADSET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
FLOOR:	DB	0
PAL:	DB	0
SET:	DB	0
NUMPAT1:DB	0
NUMPAT2:DB	0

