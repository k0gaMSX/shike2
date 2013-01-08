	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC


MASKY		EQU	128		;Y COORDENATE OF BITMAP MASKS
MASKTMP		EQU	00D4H		;XY COORDENATE FOR MASK OPERATIONS
MASKRGHTUP	EQU	0		;MASK RIGTH UP
MASKLEFTUP	EQU	1		;MASK LEFT UP
MASKRGHTDW	EQU	2		;MASK RIGTH DOWN
MASKLEFTDW	EQU	3		;MASK LEFT DOWN
NOMASK		EQU	15		;NO USE ANY MASK
MASKTRANS	EQU	16		;COPY ONLY WITH TRANSPARENT COLOR

ISOXY		EQU	0		;ISO REGION IN PLANE X-Y
ISOXZ		EQU	1		;ISO REGION IN PLANE X-Z
ISOYZ		EQU	2		;ISO REGION IN PLANE Y-Z

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE

	CSEG

ISVISIBLE:
	LD	A,E
	CP	NR_SCRROW
	JR	NC,V.NO

	LD	A,D
	CP	NR_SCRCOL
	JR	NC,V.NO
	LD	A,1
	OR	A
	RET				; Z = 0, NO VISIBLE

V.NO:	XOR	A			; Z = 1, VISIBLE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT, LOWER -> Y INCREMENT
;		(TILE) = INITIAL TILE
;		(ACPAGE) = PAGE
;		(METAPAT) = META PATTERN SIZE (SAME FORMAT TILEINC)

	CSEG
	PUBLIC	MARKREGION

MARKREGION:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
;
;         LR
;        LIIIR
;	LIIIII
;        IIII
;         II


MXYREGION:
	LD	BC,(METAPAT)		;PAINT TILES L
	LD	E,B
	PUSH	DE			;ONLY ARE SIGNIFICATIVES LOWER PART
	LD	A,C
	NEG
	LD	E,A
	PUSH	DE			;ONLY ARE SIGNIFICATIVES LOWER PART
	LD	BC,(TILEINC)
	LD	DE,(TILE)
	LD	HL,MARKMETATIL
	CALL	ISOLINE

	LD	BC,(METAPAT)		;PAINT TILES R
	LD	E,B
	PUSH	DE			;ONLY ARE SIGNIFICATIVES LOWER PART
	PUSH	BC			;ONLY ARE SIGNIFICATIVES LOWER PART
	LD	BC,(TILEINC)
	LD	B,C
	LD	DE,(LASTMETA)
	INC	D
	LD	HL,MARKMETATIL
	CALL	ISOLINE

	LD	HL,MARKMETATIL		;PAINT TILES I
	LD	DE,(TILE)
	INC	E
	LD	BC,(TILEINC)
	CALL	XY.HELPER

	LD	HL,MARKMETATIL
	LD	DE,(TILE)
	INC	E
	INC	D
	LD	BC,(TILEINC)
	;CONTINUE IN XY.HELPER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = CALLBACK FUNCTION
;	DE = INITIAL TILE
;	BC = X/Y INCREMENTS (SAME FORMAT THAN TILEINC)
;	(METAPAT) = META PATTERN SIZE (SAME FORMAT TILEINC)

	CSEG

XY.HELPER:
	LD	IY,REGXY
	LD	(IY+0),L
	LD	(IY+1),H
	LD	(IY+2),B			;NUMBER DOTS INNER
	LD	(IY+5),C			;NUMBER DOTS OUTER
	LD	BC,(METAPAT)
	LD	(IY+3),B			;X INCREMENT INNER
	LD	A,C
	NEG
	LD	(IY+4),A			;Y INCREMENT INNER
	LD	(IY+6),B			;X INCREMENT OUTER
	LD	(IY+7),C			;Y INCREMENT OUTER
	JR	RECTANGLE

	DSEG
REGXY:	DS	8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = INTIAL TILE POSITION
;		IY = POINTER TO STRUCT:
;		   (IY+0) = CALLBACK FUNCTION
;		   (IY+2) = NUMBER OF DOTS INNER
;		   (IY+3) = X INCREMENT INNER
;		   (IY+4) = Y INCREMENT INNER
;		   (IY+5) = NUMBER OF DOTS OUTER
;		   (IY+6) = X INCREMENT OUTER
;		   (IY+7) = Y INCREMENT OUTER


	CSEG
	EXTRN	GETCHAR,VDPSYNC

RECTANGLE:
	LD	H,0
	LD	L,(IY+6)
	PUSH	HL		;PARAMETER X INCREMENT
	LD	L,(IY+7)
	PUSH	HL		;PARAMETER Y INCREMENT
	LD	HL,R.AUX
	LD	B,(IY+5)
	CALL	ISOLINE		;WE CAN NOT USE JP HERE BECAUSE IT CAUSES
	RET			;A DIFFERENT STACK

R.AUX:	LD	H,0
	LD	L,(IY+3)
	PUSH	HL		;PARAMETER X INCREMENT
	LD	L,(IY+4)
	PUSH	HL		;PARAMETER Y INCREMENT
	LD	L,(IY+0)
	LD	H,(IY+1)	;HL = CALLBACK FUNCTION
	LD	B,(IY+2)
	CALL	ISOLINE		;WE CAN NOT USE JP HERE BECAUSE IT CAUSES
	RET			;A DIFFERENT STACK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = INTIAL TILE POSITION
;		HL = CALLBACK FUNCTION
;		B = NUMBER OF ITERATIONS (NUMBER OF 'DOTS' IN THE LINE)
;		(SP) = RETURN ADDRESS
;		(SP+2) = INCREMENT Y
;		(SP+4) = INCREMENT X


	CSEG
	PUBLIC	ISOLINE,RECTANGLE

ISOLINE:PUSH	IX
	LD	IX,+4
	ADD	IX,SP
	PUSH	IY

	LD	A,B			;IF THE SIZE IS 0 THEN RETURN
	OR	B
	JR	Z,I.END

I.LOOP:	PUSH	BC			;LOOP OVER ISO X DRAWING AN
	PUSH	DE			;ISOMETRIC LINE
	PUSH	HL

	LD	BC,L.RET
	PUSH	BC
	JP	(HL)			;GO TO CALLBACK FUNCTION

L.RET:	POP	HL
	POP	DE
	POP	BC

	LD	A,D
	ADD	A,(IX+2)
	LD	D,A

	LD	A,E
	ADD	A,(IX+0)
	LD	E,A
	DJNZ	I.LOOP

I.END:	POP	IY		;RESTORE IX AND IY
	POP	IX
	POP	HL		;GET RETURN ADDRESS
	POP	DE		;REMOVE PARAMETERS
	POP	DE
	JP	(HL)		;JUMP TO RETURN ADDRESS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = X TILE POSITION
;		E = Y TILE POSITION


	CSEG
        PUBLIC	TILE2XY

TILE2XY:
	LD	A,E			;CONVERT FROM TILE SPACE
	ADD	A,A			;TO SCREEN COORDINATES
	ADD	A,A
	ADD	A,A
	LD	E,A

	LD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	D,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = PATTERN NUMBER

	CSEG
	PUBLIC	PAT2XY

PAT2XY:
	LD	A,D			;CONVERT FROM PATTERN SPACE TO
	AND	0F0H			;COORDENATES
	RRCA
	LD	E,A
	LD	A,D
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	D,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = PATTERN NUMBER

	CSEG
	PUBLIC	PAT2TILE

PAT2TILE:
	LD	A,D		;CONVERT FROM PATTERN SPACE (0-255)
	AND	0F0H		;TO TILE COORDENATES (D = X, E = Y)
	RRCA
	RRCA
	RRCA
	RRCA
	LD	E,A
	LD	A,D
	AND	0FH
	LD	D,A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(I.PATTERN) = PATTERN NUMBER
;		(ACPAGE) = PAGE
;		(MASK) = MASK USED IN THE TILE

	CSEG
	EXTRN	LMMM,HMMM,VDPPAGE

DRAWTILE:
	CALL	ISVISIBLE
	RET	Z

	PUSH	DE			;CALCULATE PATTERN COORDINATES
	LD	DE,(I.PATTERN-1)
	CALL	PAT2XY
	LD	L,E			;CALCULATE TILE COORDINATES
	LD	H,D
	POP	DE
	CALL	TILE2XY

	LD	A,(MASK)
	CP	NOMASK
	JR	Z,DT.NOMASK
	CP	MASKTRANS
	JR	Z,DT.TRANS
	JR	DT.MASK

DT.NOMASK:
	LD	BC,1008H
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	JP	HMMM

DT.TRANS:
	LD	BC,1008H
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	JP	LMMM

DT.MASK:PUSH	DE			;DE = TILE COORDENATES
	PUSH	HL			;HL = PATTERN COORDINATES
	LD	A,(MASK)		;CALCULATE MASK COORDENATES
	LD	L,A
	AND	0FH
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,A
	LD	A,L
	AND	0F0H
	RRCA
	ADD	A,MASKY
	LD	L,A
	LD	DE,MASKTMP
	LD	BC,1008H
	CALL	HMMM			;COPY THE MASK TO THE TEMPORAL SPACE

	POP	HL
	LD	A,LOGAND
	LD	(LOGOP),A
	LD	L,E
	LD	H,D
	LD	DE,MASKTMP
	LD	BC,1008H
	CALL	LMMM			;COPY THE PATTERN WITH AND OPERATION

	POP	DE
	LD	HL,MASKTMP
	LD	BC,1008H
	LD	A,(ACPAGE)
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	JP	LMMM			;COPY THE RESULT TO THE SCREEN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN SIZE (SAME FORMAT TILEINC)
;		DE = INITIAL TILE
;		(ACPAGE) = PAGE

MARKMETATIL:
	LD	HL,MARKTILE
	JR	META

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(PATTERN) = PATTERN NUMBER
;		(ACPAGE) = PAGE
;		(METAPAT) = SIZE OF THE META PATTERN (SAME FORMAT OF TILEINC)
;		(MASK) = MASK USED

	CSEG

DRAWMETAPAT:
        LD	HL,DRAWTILE
	JR	META
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN SIZE (SAME FORMAT TILEINC)
;		(PATTERN) = INITIAL TILE
;		(ACPAGE) = PAGE

	CSEG
	PUBLIC	MARKMETAPAT


MARKMETAPAT:
	LD	DE,(PATTERN-1)
	CALL	PAT2TILE
	LD	HL,MARKTILE
	;CONTINUE IN META

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN SIZE (SAME FORMAT TILEINC)
;		DE = INTIAL TILE
;		HL = CALLBACK FUNCTION


META:
	LD	(LASTMETA),DE		;ALLOW US TO KNOW WHICH WAS LAST
	LD	IY,METADAT		;META TILE WHERE SOME OPERARION
	LD	(IY+0),L		;WAS PERFORMED
	LD	(IY+1),H
	LD	BC,(METAPAT)
	LD	(IY+2),B			;NUMBER DOTS INNER
	LD	(IY+5),C			;NUMBER DOTS OUTER
	LD	(IY+3),1			;X INCREMENT INNER
	LD	(IY+4),0			;Y INCREMENT INNER
	LD	(IY+6),0			;X INCREMENT OUTER
	LD	(IY+7),1			;Y INCREMENT OUTER
	JP	RECTANGLE

	DSEG
METADAT:	DS	8
LASTMETA:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT

	CSEG
	EXTRN	LMMV

MARKTILE:
	CALL	ISVISIBLE
	RET	Z
	CALL	TILE2XY			;TRANSFORM IT TO COORDINATES

	LD	A,LOGXOR
	LD	(LOGOP),A
	LD	A,MARKCOLOR
	LD	(FORCLR),A

	LD	BC,1008H
	JP	LMMV

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
	PUBLIC	METAPAT,ISOTILE,TILE,TILEINC,PATTERN
ISOTYPE:	DB	0		;ACTUAL ISO REGION. PARAMETER BY DEFAULT
MASK:		DB	0		;ACTUAL TILE MASK. PARAMETER BY DEFAULT
TILE:		DW	0		;ACTUAL TILE. PARAMETER BY DEFAULT
PATTERN:	DB	0		;ACTUAL PATTERN. PARAMETER BY DEFAULT
TILEINC:	DW	0		;ACTUAL INCREMENT. PARAMETER BY DEFAULT
ISOTILE:	DB	0		;IS 1 WHEN TILE MODE IS SELECTED
METAPAT:	DW	0		;SIZE OF META PATTERN
I.PATTERN:	DB	0		;LOCAL COPY OF PATTERN

