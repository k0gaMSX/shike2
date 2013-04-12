
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
	LD	(FPTR),HL

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
	LD	A,(NUMPAT1)
	LD	L,A
	PUSH	HL
	LD	A,(NUMPAT2)
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



	CSEG
	EXTRN	PUTS

PUTPATTERN1:
	LD	DE,TXTPAT1
	JP	PUTS

PUTPATTERN2:
	LD	DE,TXTPAT2
	JP	PUTS

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

TXTPAT1:	DB	"PATTERN 1",10,0
TXTPAT2:	DB	"PATTERN 2",10,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
FPTR:	DW	0			;FLOOR POINTER
FLOOR:	DB	0
PAL:	DB	0
SET:	DB	0
NUMPAT1:DB	0
NUMPAT2:DB	0

