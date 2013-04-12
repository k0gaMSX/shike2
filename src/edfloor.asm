
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC
	INCLUDE	EVENT.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDFLOOR
	EXTRN	LOADSET,EDINIT,MPRESS,VDPSYNC,CARTPAGE,LISTEN

EDFLOOR:CALL	EDINIT			;COMMON INITIALIZATION
	LD	A,(SET)
	LD	E,A
	CALL	LOADSET			;LOAD GRAPHICS FOR SELECTED SET

ED.LOOP:LD	E,LEVELPAGE		;PUTS DATA OF LEVELS
	CALL	CARTPAGE
	CALL	GETFDATA		;CALCULATE NUMPAT1 AND NUMPAT2
	CALL	SHOWSCR			;PAINT THE SCREEN
	CALL	VDPSYNC			;WAIT TO THE VDP
	LD	DE,RECEIVERS
	CALL	LISTEN			;WAIT AN EVENT
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

	CSEG

GETFDATA:
	LD	A,(FLOOR)
	LD	E,A
	CALL	GETFLOOR		;GET THE POINTER TO THE FLOOR

	PUSH	HL
	CALL	GETNUMPAT		;CALCULATE NUMPAT1
	LD	(NUMPAT1),A
	POP	HL
	LD	DE,NR_LAYERS
	ADD	HL,DE
	CALL	GETNUMPAT
	LD	(NUMPAT2),A		;CALCULATE NUMPAT2
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
	EXTRN	HMMV

CLEANSTACK:
	LD	DE,80*256 + 78
	LD	BC,16*256 + 16
	XOR	A
	LD	(FORCLR),A
	JP	HMMV			;BLACK RECTANGLE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = PATTERN STACK
;	BC = SCREEN COORDINATES

	CSEG
	EXTRN	VDPPAGE,LMMM

PSTACK:	EX	DE,HL
	LD	(P.COORD),BC
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A

	LD	B,NR_LAYERS

P.LOOP:	LD	A,(HL)			;0 MARKS THE END OF A TILE STACK
	OR	A
	RET	Z

	PUSH	HL
	PUSH	BC
	LD	E,A
	CALL	PAT2XY			;TRANSFORM THE PATTER NUMBER TO XY
	LD	DE,(P.COORD)
	LD	BC,1008H
	CALL	LMMM			;AND COPY THE PATTERN TO THE DESTINE
	POP	BC
	POP	HL
	INC	HL
	DJNZ	P.LOOP
	RET

	DSEG
P.COORD:DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	SETPAL,LOCATE,PRINTF,GLINES

SHOWSCR:CALL	CLEANSTACK		;CLEAN THE PATTERN STACK VISUALIZATION

	LD	DE,(PAL)
	CALL	GETPAL
	CALL	SETPAL			;LOAD THE SELECTED PALETE

	LD	DE,0
	CALL	LOCATE			;LOCATE THE CURSOR IN THE BEGINNING
	LD	H,0			;OF SCREEN
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
	CALL	PRINTF			;PRINT THE TEXT INFORMATION

	LD	DE,FLOORG
	LD	C,15
	CALL	GLINES			;DRAW ALL THE SCREEN LINES

	LD	DE,(FLOOR)
	CALL	GETFLOOR

	PUSH	HL			;PRINT THE UPPER PATTERN STACK
	EX	DE,HL
	LD	BC,80*256 + 78
	CALL	PSTACK

	POP	HL
	LD	DE,NR_LAYERS
	ADD	HL,DE
	EX	DE,HL			;PRINT THE LOWER PATTERN STACK
	LD	BC,80*256 + 86
	JP	PSTACK


;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
FLOORG:	DB	4,  80, 30,  110, 30,  0,  8,  0,  8
	DB	2,  80, 30,   80, 54, 30,  0, 30,  0
	DB	3,  80, 78,   96, 78,  0,  8,  0,  8
	DB	2,  80, 78,   80, 94, 16,  0, 16,  0
	DB	0

FMT:	DB	10,10,10,10
	DB	9,9,"     FLOOR",9,"%03d",10
	DB	9,9,"     PALETE",9,"%3d",10
	DB	9,9,"     SET",9,"%3d",10
	DB	10,10,10
	DB	9,9,9," %d",10
	DB	9,9,9," %d",0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = PATTERN NUMBER
;OUTPUT:HL = COORDENATES OF THE PATTERN

	CSEG

PAT2XY:	LD	A,E
	AND	0F0H
	RRCA
	LD	L,A

	LD	A,E
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	H,A
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
	EXTRN	SELPAT

PEVENT:	CP	MS_BUTTON1		;MOUSE 1 ADDS A PATTERN
	LD	A,(P.NUM)
	JR	NZ,P1.1

	CP	NR_LAYERS
	CALL	NZ,SELPAT
	LD	DE,(P.NUM)
	LD	D,A
	LD	BC,(P.OFFSET)
	CALL	NZ,ADDLAYER
	RET

P1.1:	OR	A			;MOUSE 2 DELS A PATTERN
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
	CP	MS_BUTTON1		;BUTTON 1 INCREMENT FLOOR NUMBER
	LD	A,(FLOOR)
	JR	NZ,F.DEC
	INC	A
	JR	F.RET

F.DEC:	DEC	A			;BUTTON 2 DECREMENT FLOOR NUMBER
F.RET:	LD	(FLOOR),A

	RET

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG
	EXTRN	LOADSET

CHANGESET:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENT SET NUMBER
	LD	A,(SET)
	JR	NZ,S.DEC
	CP	NR_PATSET-1
	RET	Z
	INC	A
	JR	S.RET

S.DEC:	OR	A			;BUTTON 2 DECREMENT SET NUMBER
	RET	Z
	DEC	A
S.RET:	LD	(SET),A
	LD	E,A			;THERE IS A SET CHANGE, SO UPDATE
	JP	LOADSET			;THE GRAPHICS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DSEG
FLOOR:	DB	0
PAL:	DB	0
SET:	DB	0
NUMPAT1:DB	0
NUMPAT2:DB	0

