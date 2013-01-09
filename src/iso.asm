	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC
	INCLUDE ISO.INC
	INCLUDE VDP.INC

MASKY		EQU	128		;Y COORDENATE OF BITMAP MASKS
MASKTMP		EQU	00D4H		;XY COORDENATE FOR MASK OPERATIONS
MASKRGHTUP	EQU	0		;MASK RIGTH UP
MASKLEFTUP	EQU	1		;MASK LEFT UP
MASKRGHTDW	EQU	2		;MASK RIGTH DOWN
MASKLEFTDW	EQU	3		;MASK LEFT DOWN
NOMASK		EQU	15		;NO USE ANY MASK
MASKTRANS	EQU	16		;COPY ONLY WITH TRANSPARENT COLOR

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
;		(METAPAT) = META PATTERN Y SIZE

	CSEG
	PUBLIC	MARKREGION,DRAWREGION

DRAWREGION:
	LD	A,(ISOCMD)
	CP	ISOXY
	JP	Z,DXYREGION
	CP	ISOXZ
	JP	Z,DXZREGION
	CP	ISOYZ
	JP	Z,DYZREGION
	RET

MARKREGION:
	LD	A,(ISOCMD)
	CP	ISOXY
	JP	Z,MXYREGION
	CP	ISOXZ
	JP	Z,MXZREGION
	CP	ISOYZ
	JP	Z,MYZREGION
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	  U
;	 UI
;	UII
;	III
;	IID
;	ID
;	D

DXZREGION:
	LD	HL,DRAWMTILE.LFUP
	LD	(XZ.TILESU),HL		;SET ACTIONS FOR THE DIFFERENT TILES
	LD	HL,DRAWMTILE.RGDW
	LD	(XZ.TILESD),HL		;OF A XZ REGION
	LD	HL,DRAWMTILE
	LD	(XZ.TILESI),HL
	JR	XZREGION

MXZREGION:
	CALL	MREGION

XZREGION:
	LD	A,-1			;DEFINE HOW A VREGION IS TRANSFORMED
	LD	(DR.INCX),A		;IN A XZ REGION
	LD	A,1
	LD	(DR.INCY),A
	JR	VREGION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	U
;	IU
;	IIU
;	DII
;	 DI
;	  D

	CSEG

DYZREGION:
	LD	HL,DRAWMTILE.RGUP
	LD	(YZ.TILESU),HL		;SET ACTIONS FOR THE DIFFERENT TILES
	LD	HL,DRAWMTILE.LFDW
	LD	(YZ.TILESD),HL		;OF A YZ REGION
	LD	HL,DRAWMTILE
	LD	(YZ.TILESI),HL
	JR	YZREGION

MYZREGION:
	CALL	MREGION

YZREGION:
	LD	A,1			;DEFINE HOW A VREGION IS TRANSFORMED
	LD	(DR.INCX),A		;IS TRANSFORMED IN A YZREGION
	LD	(DR.INCY),A
        JR	VREGION


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MREGION:LD	HL,MARKMETATIL		;IN MARK COMMANDS ALL THE ACTIONS
	LD	(YZ.TILESU),HL		;ARE ALWAYS MARKMETATIL
	LD	(YZ.TILESI),HL
	LD	(YZ.TILESD),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


VREGION:LD	DE,(DR.INCX)		;PAINT TILES U
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	DE,(DR.INCY)		;PAINT TILES U
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	DE,(TILE)
	LD	BC,(TILEINC)
	LD	HL,(YZ.TILESU)
	CALL	ISOLINE

	LD	BC,(TILEINC)		;PAINT TILES I
	LD	IY,REGYZ
	LD	HL,(YZ.TILESI)
	LD	(IY+0),L
	LD	(IY+1),H
	LD	(IY+2),B		;NUMBER DOTS INNER
	LD	(IY+5),C		;NUMBER DOTS OUTER
	LD	A,(DR.INCX)
	LD	(IY+3),A		;X INCREMENT INNER
	LD	A,(DR.INCY)
	LD	(IY+4),A		;Y INCREMENT INNER
	LD	(IY+6),0		;X INCREMENT OUTER
	LD	A,(METAPAT)
	LD	(IY+7),A		;Y INCREMENT OUTER
	LD	DE,(TILE)
	ADD	A,E
	LD	E,A
	CALL	RECTANGLE

	LD	A,(DR.INCX)		;PAINT TILES D
	NEG
	LD	E,A
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	A,(DR.INCY)
	NEG
	LD	E,A
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	A,(METAPAT)
	LD	DE,(LASTMETA)
	ADD	A,E
	LD	E,A
	LD	BC,(TILEINC)
	LD	HL,(YZ.TILESD)
	CALL	ISOLINE			;IT CAN NOT BE A JP BECAUSE ISOLINE
	RET				;NEEDS AN USUAL STACK

	DSEG
DR.INCX:	DB	0
DR.INCY:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	  LR
;	 LIIR
;	LIIII
;	IIII
;	 II

	CSEG

DXYREGION:
	LD	HL,DRAWMTILE.LFUP
	LD	(XY.TILESL),HL		;SET ACTIONS FOR THE DIFFERENT TILES
	LD	HL,DRAWMTILE.RGUP
	LD	(XY.TILESR),HL		;OF A XY REGION
	LD	HL,DRAWMTILE
	LD	(XY.TILESI),HL
	JR	XYREGION

MXYREGION:
	CALL	MREGION

;XYREGION ONLY ADMITS USUAL PATTERNS, META PATTERNS CAN CAUSE PROBLEMS

XYREGION:
	LD	E,1			;PAINT TILES L
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	E,-1
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	BC,(TILEINC)
	LD	DE,(TILE)
	LD	HL,(XY.TILESL)
	CALL	ISOLINE

	LD	E,1			;PAINT TILES R
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	DE,(LASTMETA)
	INC	D
	LD	BC,(TILEINC)
	LD	B,C
	LD	HL,(XY.TILESR)
	CALL	ISOLINE

	LD	DE,(TILE)		;PAINT TILES I
	INC	E
	LD	BC,(TILEINC)
	LD	HL,(XY.TILESI)
	CALL	XY.HELPER

	LD	DE,(TILE)
	INC	D
	INC	E
	LD	BC,(TILEINC)
	LD	HL,(XY.TILESI)
	;CONTINUE IN XY.HELPER

	DSEG

XZ.TILESU:
YZ.TILESU:
XY.TILESL:	DW	0

XZ.TILESD:
YZ.TILESD:
XY.TILESR:	DW	0

XZ.TILESI:
YZ.TILESI:
XY.TILESI:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = CALLBACK FUNCTION
;	DE = INITIAL TILE
;	BC = X/Y INCREMENTS (SAME FORMAT THAN TILEINC)
;	(METAPAT) = META PATTERN Y SIZE

	CSEG

XY.HELPER:
	LD	IY,REGXY
	LD	(IY+0),L
	LD	(IY+1),H
	LD	(IY+2),B			;NUMBER DOTS INNER
	LD	(IY+5),C			;NUMBER DOTS OUTER
	LD	BC,(METAPAT)
	LD	(IY+3),1			;X INCREMENT INNER
	LD	A,C
	NEG
	LD	(IY+4),A			;Y INCREMENT INNER
	LD	(IY+6),1			;X INCREMENT OUTER
	LD	(IY+7),C			;Y INCREMENT OUTER
	JR	RECTANGLE

	DSEG
REGXZ:
REGYZ:
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
	CALL	L.CALL			;GO TO CALLBACK FUNCTION
	POP	HL
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
L.CALL:	JP	(HL)		;JUMP TO RETURN ADDRESS

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
	LD	H,D                     ;HL = PATTERN COORDENATES
	POP	DE
	CALL	TILE2XY			;DE = TILE COORDENATES

	LD	BC,1008H
	LD	A,(MASK)
	CP	NOMASK
	JR	Z,DT.NOMASK
	CP	MASKTRANS
	JR	Z,DT.TRANS
	JR	DT.MASK

DT.NOMASK:
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	JP	HMMM

DT.TRANS:
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	JP	LMMM

DT.MASK:PUSH	DE			;DE = TILE COORDENATES
	PUSH	HL			;HL = PATTERN COORDINATES
	LD	A,(MASK)		;CALCULATE MASK COORDENATES
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,A
	LD	L,MASKY
	LD	A,MASKPAGE
	LD	(VDPPAGE),A
	LD	DE,MASKTMP
	CALL	HMMM			;COPY THE MASK TO THE TEMPORAL SPACE

	POP	HL
	LD	A,LOGAND
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	DE,MASKTMP
	LD	BC,1008H
	CALL	LMMM			;COPY THE PATTERN WITH AND OPERATION

	POP	DE
	LD	HL,MASKTMP
	LD	A,(ACPAGE)
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	LD	BC,1008H
	JP	LMMM			;COPY THE RESULT TO THE SCREEN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN Y SIZE
;		DE = INITIAL TILE
;		(ACPAGE) = PAGE

MARKMETATIL:
	LD	HL,MARKTILE
	JP	META

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(PATTERN) = PATTERN NUMBER
;		(ACPAGE) = PAGE
;		(METAPAT) = Y SIZE OF THE META PATTERN
;		(MASK) = MASK USED

	CSEG
	PUBLIC	DRAWMTILE

DRAWMTILE:
	LD	A,(PATTERN)
	LD	(I.PATTERN),A
	LD	A,NOMASK
	LD	(MASK),A
	LD	HL,DT
	JP	META

DRAWMTILE.LFUP:
	LD	A,(PATTERN)
	LD	(I.PATTERN),A
	LD	A,MASKLEFTUP
	LD	(MASK),A
	LD	HL,DT.UP
	JP	META

DRAWMTILE.LFDW:
	LD	A,(PATTERN)
	LD	(I.PATTERN),A
	LD	A,NOMASK
	LD	(MASK),A
	LD	A,MASKLEFTDW
	LD	(DT.DMASK),A
	LD	HL,DT.DW
	JP	META


DRAWMTILE.RGUP:
	LD	A,(PATTERN)
	LD	(I.PATTERN),A
	LD	A,MASKRGHTUP
	LD	(MASK),A
	LD	HL,DT.UP
	JP	META

DRAWMTILE.RGDW:
	LD	A,(PATTERN)
	LD	(I.PATTERN),A
	LD	A,NOMASK
	LD	(MASK),A
	LD	A,MASKRGHTDW
	LD	(DT.DMASK),A
	LD	HL,DT.DW
	JP	META


DT:	CALL	DRAWTILE
	LD	A,(I.PATTERN)
	ADD	A,16
	LD	(I.PATTERN),A
	RET

DT.UP:	CALL	DRAWTILE
	LD	A,NOMASK
	LD	(MASK),A
	LD	A,(I.PATTERN)
	ADD	A,16
	LD	(I.PATTERN),A
	RET

DT.DW:	LD	HL,METACNT
	LD	A,(METAPAT)
	CP	(HL)
	JR	NZ,DT.DW1
	LD	A,(DT.DMASK)
	LD	(MASK),A
DT.DW1:	INC	(HL)
	LD	(METACNT),A
	CALL	DRAWTILE
	LD	A,(I.PATTERN)
	ADD	A,16
	LD	(I.PATTERN),A
	RET

	DSEG
DT.DMASK:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN Y SIZE
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
;INPUT:		(METAPAT) = META PATTERN Y SIZE
;		DE = INTIAL TILE
;		HL = CALLBACK FUNCTION

	CSEG

META:	LD	A,1			;MARK WE ARE GOING TO DEAL FIRST
	LD	(METACNT),A		;ELEMENT
	LD	(LASTMETA),DE		;ALLOW US TO KNOW WHICH WAS LAST
	LD	C,0			;META TILE WHERE SOME OPERARION
	PUSH	BC			;WAS PERFORMED
	LD	C,1
	PUSH	BC
	LD	BC,(METAPAT-1)
	CALL	ISOLINE			;IT CAN NOT BE A JP BECAUSE ISOLINE
	RET				;NEEDS A USUAL STACK

	DSEG
LASTMETA:	DW	0
METACNT:	DB	0		;COUNTER USED IN SOME CALLBACKS

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
	PUBLIC	ISOCMD,METAPAT,TILE,TILEINC,PATTERN
MASK:		DB	0		;ACTUAL TILE MASK. PARAMETER BY DEFAULT
TILE:		DW	0		;ACTUAL TILE. PARAMETER BY DEFAULT
PATTERN:	DB	0		;ACTUAL PATTERN. PARAMETER BY DEFAULT
TILEINC:	DW	0		;ACTUAL INCREMENT. PARAMETER BY DEFAULT
METAPAT:	DB	0		;SIZE OF META PATTERN
ISOCMD:		DB	0		;ISO COMMAND
I.PATTERN:	DB	0		;LOCAL COPY OF PATTERN

