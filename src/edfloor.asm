
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDFLOOR
	EXTRN	EDINIT,MPRESS,VDPSYNC,CARTPAGE

EDFLOOR:CALL	EDINIT
	LD	E,LEVELPAGE
	CALL	CARTPAGE

ED.LOOP:CALL	SHOWSCR
	CALL	VDPSYNC
	CALL	MPRESS
	CP	2
	JR	NZ,ED.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	LOCATE,PRINTF,GLINES

SHOWSCR:LD	DE,0
	CALL	LOCATE
	LD	H,0
	LD	A,(NUMPAT1)
	LD	L,A
	PUSH	HL
	LD	A,(NUMPAT2)
	LD	L,A
	PUSH	HL
	LD	A,(TILESET)
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
	DSEG
FLOOR:	DB	0
PAL:	DB	0
TILESET:DB	0
NUMPAT1:DB	0
NUMPAT2:DB	0

