	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC
	INCLUDE MAPPER.INC
	INCLUDE VDP.INC

MASKY		EQU	212		;Y COORDENATE OF BITMAP MASKS
MASKTMP		EQU	40D4H		;XY COORDENATE FOR TMP MASK OPERATIONS
MASKPAGE	EQU	0		;PAGE OF MASKS

MASKRGHTUP	EQU	0		;MASK RIGTH UP
MASKLEFTUP	EQU	1		;MASK LEFT UP
MASKRGHTDW	EQU	2		;MASK RIGTH DOWN
MASKLEFTDW	EQU	3		;MASK LEFT DOWN
NOMASK		EQU	4		;NO USE ANY MASK
MASKTRANS	EQU	5		;COPY ONLY WITH TRANSPARENT COLOR

MARKCOLOR	EQU	12
NOZVALUE	EQU	31		;Z VALUE WITH ALL THE BITS TO 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;THE TILES VALUES ARE CODED LIKE A SPARSE MATRIX, WHERE FOR EACH TILE POSITION
;(X,Y COORDENATES) WE HAVE A STACK OF PATTERNS & MASK AND THE VALUE OF THE
;Z COORDENATE OF THE TILE. CODED IN C:
;
;struct tile {
;	unsigned mask : 3;
;	unsigned zval : 5;
;	unsigned pattern : 8;
;};
;
;struct tile_stack {
;	struct tile stack[NR_PATTIL];
;};
;
;struct tile_stack buffer[NR_SCRCOL][NR_SCRROW];
;

ZSTACKSIZ	EQU	NR_PATTIL*2
ZROWSIZ		EQU	NR_SCRCOL*ZSTACKSIZ
ZBUFFERSIZ	EQU	NR_SCRROW*ZROWSIZ

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
;INPUT:	(TILE) = ACTUAL SELECTED TILE
;	(ZVALUE) = ACTUAL Z VALUE
;OUTPUT:DE = TILE RENDERED USING Z VALUE

	CSEG
	PUBLIC	ZTILE

ZTILE:	LD	DE,(TILE)
	LD	A,(ZVALUE)
	NEG
	ADD	A,E
	LD	E,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT, LOWER -> Y INCREMENT
;		(TILE) = INITIAL TILE
;		(ZVALUE) = INITIAL Z VALUE
;		(ACPAGE) = PAGE
;		(METAPAT) = META PATTERN Y SIZE

	CSEG
	PUBLIC	MARKREGION,DRAWREGION

DRAWREGION:
	LD	HL,DR.VEC
	JR	CMD

MARKREGION:
	LD	HL,MR.VEC

CMD:	CALL	ZTILE
	LD	(I.TILE),DE
	LD	A,(MAPCMD)		;TAKE THE CORRECT FUNCTION POINTER
	ADD	A,A			;OF THE HL ARRAY
	ADD	A,L
	LD	L,A
	JR	NC,DR.1
	INC	H
DR.1:	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)

DR.VEC:	DW	DXYREGION,DYZREGION,DXZREGION,DYZREGION_,DXZREGION_,DISOTILE
MR.VEC:	DW	MXYREGION,MYZREGION,MXZREGION,MYZREGION_,MXZREGION_,MISOTILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	III
;	III
;	III
;

	CSEG
DISOTILE:				;PAINT A NUMBER OF METATILES
	LD	HL,DRAWMISOTILE		;METATILES CAN HAVE WIDTH != 1
	JR	ISO.DO

MISOTILE:
	LD	HL,MARKMTILE

ISO.DO:	LD	BC,(METAPAT)		;WE WANT THAT REGION GROWS
	LD	E,0			;TOWARD UP, NOT DOWN
	PUSH	DE			;SO WE HAVE TO NEGATE THE INCREMENT
	LD	A,C
	NEG
	LD	E,A
	PUSH	DE
	LD	DE,(I.TILE)		;AND THE INITIAL POINT OF REGION
	ADD	A,E			;MUST SUBSTRACT THE SIZE OF METAPAT
	INC	A
	LD	E,A
	LD	BC,(TILEINC-1)
	CALL	ISOLINE			;ISOLINE NEEDS AN USUAL STACK, SO
	RET				;THIS CALL CAN NOT BE A JP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	  I
;	 II
;	III
;	III
;	III
;	II
;	I

	CSEG

DYZREGION_:				;SIMILAR TO DXZREGION BUT WITHOUT MASKS
	LD	HL,DRAWMTILE
	JR	YZ_.DO

MYZREGION_:
	LD	HL,MARKMTILE

YZ_.DO:	LD	(YZ.TILESI),HL
	CALL	YZREGION
	LD	BC,(TILEINC)		;PAINT TILES I
	LD	DE,(I.TILE)
	JP	DTILESI
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

	CSEG

DYZREGION:
	LD	HL,DRAWMTILE.RGUP
	LD	(YZ.TILESU),HL		;SET ACTIONS FOR THE DIFFERENT TILES
	LD	HL,DRAWMTILE.LFDW
	LD	(YZ.TILESD),HL		;OF A YZ REGION
	LD	HL,DRAWMTILE
	LD	(YZ.TILESI),HL
	JR	YZ.DO

MYZREGION:
	CALL	MREGION

YZ.DO:	CALL	YZREGION
	JR	VREGION


YZREGION:
	LD	A,-1			;DEFINE HOW A VREGION IS TRANSFORMED
	LD	(DR.INCX),A		;INTO A XZ REGION
	LD	A,-1
	LD	(DR.INCY),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	I
;	II
;	III
;	III
;	 II
;	  I

	CSEG

DXZREGION_:				;SIMILAR TO DYZREGION BUT WITHOUT MASKS
	LD	HL,DRAWMTILE
	JR	XZ_.DO

MXZREGION_:
	LD	HL,MARKMTILE

XZ_.DO:	LD	(XZ.TILESI),HL
	CALL	XZREGION
	LD	BC,(TILEINC)		;PAINT TILES I
	LD	DE,(I.TILE)
	JP	DTILESI
	RET

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

DXZREGION:
	LD	HL,DRAWMTILE.LFUP
	LD	(XZ.TILESU),HL		;SET ACTIONS FOR THE DIFFERENT TILES
	LD	HL,DRAWMTILE.RGDW
	LD	(XZ.TILESD),HL		;OF A XZ REGION
	LD	HL,DRAWMTILE
	LD	(XZ.TILESI),HL
	JR	XZ.DO

MXZREGION:
	CALL	MREGION

XZ.DO:	CALL	XZREGION
	JR	VREGION

XZREGION:
	LD	A,1			;DEFINE HOW A VREGION IS TRANSFORMED
	LD	(DR.INCX),A		;INTO A YZREGION
	LD	A,-1
	LD	(DR.INCY),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MREGION:LD	HL,MARKMTILE		;IN MARK COMMANDS ALL THE ACTIONS
	LD	(YZ.TILESU),HL		;ARE ALWAYS MARKMTILE
	LD	(YZ.TILESI),HL
	LD	(YZ.TILESD),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


VREGION:LD	DE,(DR.INCX)		;PAINT TILES D
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	DE,(DR.INCY)
	PUSH	DE			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	DE,(I.TILE)
	LD	BC,(TILEINC)
	LD	HL,(YZ.TILESD)
	CALL	ISOLINE

	LD	BC,(TILEINC)		;PAINT TILES I
	DEC	C
	LD	A,(METAPAT)
	LD	DE,(I.TILE)
	NEG
	ADD	A,E
	LD	E,A
	CALL	DTILESI

	LD	A,(DR.INCX)		;PAINT TILES U
	NEG
	LD	L,A
	PUSH	HL			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	A,(DR.INCY)		;PAINT TILES U
	NEG
	LD	L,A
	PUSH	HL			;ONLY IS SIGNIFICATIVE THE LOWER BYTE
	LD	HL,(YZ.TILESU)
	LD	A,(METAPAT)
	LD	DE,(LASTMETA)
	NEG
	ADD	A,E
	LD	E,A
	LD	BC,(TILEINC)
	CALL	ISOLINE			;IT CAN NOT BE A JP BECAUSE ISOLINE
	RET				;NEEDS AN USUAL STACK

;INPUT:	DE = SELECTED TILE
;	BC = SIZE

DTILESI:LD	IY,REGYZ		;PAINT TILES I
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
	NEG
	LD	(IY+7),A		;Y INCREMENT OUTER
	JP	RECTANGLE


	DSEG
DR.INCX:	DB	0
DR.INCY:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;	  LR
;	 LHHR
;	LHHHH
;	HHHH
;	 HH

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
	LD	DE,(I.TILE)
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

	LD	DE,(I.TILE)		;PAINT TILES H
	INC	E
	LD	BC,(TILEINC)
	LD	HL,(XY.TILESI)
	CALL	XY.HELPER

	LD	DE,(I.TILE)
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

ISO.TILES:
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
;INPUT: DE = PATTERN POSITION
;OUTPUT: A = PATTERN NUMBER

	CSEG
	PUBLIC	TILE2PAT

TILE2PAT:
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = X TILE POSITION
;		E = Y TILE POSITION


	CSEG
        PUBLIC	TILE2XY

TILE2XY:LD	A,E			;CONVERT FROM TILE SPACE
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
;INPUT:	DE = XY COORDENAYES
;OUTPUT:DE = TILE COORDENATES

XY2TILE:LD	A,E
	AND	0F8H
	RRCA
	RRCA
	RRCA
	LD	E,A
	LD	A,D
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	LD	D,A
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = PATTERN NUMBER

	CSEG
	PUBLIC	PAT2XY

PAT2XY:	PUSH	AF			;CONVERT FROM PATTERN SPACE TO
	AND	0F0H			;COORDENATES
	RRCA
	LD	E,A
	POP	AF
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	D,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = PATTERN NUMBER

	CSEG
	PUBLIC	PAT2TILE

PAT2TILE:
	PUSH	AF		;CONVERT FROM PATTERN SPACE (0-255)
	AND	0F0H		;TO TILE COORDENATES (D = X, E = Y)
	RRCA
	RRCA
	RRCA
	RRCA
	LD	E,A
	POP	AF
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
	CALL	SETZVAL			;UPDATE THE TILE STACK INFORMATION

;DRAWTILE_ IS EXACTLY THE SAME THAN DRAWTILE BUT DOESN'T CHECK VISIBILITY
;AND DOESN'T SET THE Z VALUE. IT IS USEFUL FOR REMAP, BECAUSE IN THIS
;CASE WE ARE SURE THE TILE POSITION IS CORRECT AND WE DON'T HAVE TO SET THE
;Z VALUE

DRAWTILE_:
	PUSH	DE			;CALCULATE PATTERN COORDINATES
	LD	A,(I.PATTERN)
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
;		(ACPAGE) = PAGE

	CSEG

MTILE:
	LD	DE,(TILE)
	;CONTINUE IN MARKMTILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN Y SIZE
;		DE = INITIAL TILE
;		(ACPAGE) = PAGE
	CSEG

MARKMTILE:
	LD	HL,MARKTILE
	JP	META

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(PATTERN) = PATTERN NUMBER
;		(ACPAGE) = PAGE
;		(METAPAT) = Y SIZE OF THE META PATTERN
;		(MASK) = MASK USED

	CSEG

DRAWMISOTILE:
	LD	A,MASKTRANS
	JR	DMTILE1

DRAWMTILE:
	LD	A,NOMASK

DMTILE1:LD	(MASK),A
	LD	HL,DT
	JP	META

DRAWMTILE.LFUP:
	LD	A,MASKLEFTUP
	LD	(MASK),A
	LD	HL,DT.UP
	JP	META

DRAWMTILE.LFDW:
	LD	A,NOMASK
	LD	(MASK),A
	LD	A,MASKLEFTDW
	LD	(DT.DMASK),A
	LD	HL,DT.DW
	JP	META


DRAWMTILE.RGUP:
	LD	A,MASKRGHTUP
	LD	(MASK),A
	LD	HL,DT.UP
	JP	META

DRAWMTILE.RGDW:
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
	LD	A,(PATTERN)
	CALL	PAT2TILE
	LD	HL,MARKTILE
	;CONTINUE IN META

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(METAPAT) = META PATTERN SIZE
;		DE = INTIAL TILE
;		HL = CALLBACK FUNCTION

	CSEG

META:	LD	A,1			;MARK WE ARE GOING TO DEAL FIRST
	LD	(METACNT),A		;ELEMENT
	LD	(LASTMETA),DE		;ALLOW US TO KNOW WHICH WAS LAST
	LD	BC,(METAPAT)
	LD	A,(PATTERN)		;IF (HL) NEEDS (PATTERN) THEN
					;EACH LINE NEEDS A DIFFERENT ONE
M.LOOP:	PUSH	DE
	PUSH	HL
	PUSH	AF
	PUSH	BC
	LD	(I.PATTERN),A
	LD	B,C
	LD	C,0			;META TILE WHERE SOME OPERARION
	PUSH	BC			;WAS PERFORMED
	LD	C,1
	PUSH	BC
	CALL	ISOLINE			;IT CAN NOT BE A JP BECAUSE ISOLINE
	POP	BC			;NEEDS A USUAL STACK
	POP	AF
	POP	HL
	POP	DE
	INC	A			;INCREMENT THE PATTERN
	INC	D			;INCREMENT X TILE
	DJNZ	M.LOOP

	RET

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

	CSEG
	PUBLIC	RESETMAP
	EXTRN	MEMSET

RESETMAP:
	XOR	A
	LD	(ZVALUE),A
	LD	A,0FFH
	LD	HL,ZBUFFER
	LD	BC,ZBUFFERSIZ
	JP	MEMSET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(ZVALUE) = ACTUAL Z VALUE
;	(MAPCMD) = ACTUAL MAPPER COMMAND
;OUTPUT:A = Z VALUE

	CSEG
	PUBLIC	CALZVAL

CALZVAL:LD	A,(MAPCMD)
	CP	MAPXY
	JR	Z,CZ.XY
	LD	A,(ZVALUE)
	LD	HL,(I.TILE)
	ADD	A,L
	SUB	E
	RET

CZ.XY:	LD	A,(ZVALUE)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ACTUAL TILE
;OUTPUT:HL = ADDRESS OF TILE STACK

	CSEG

ADDRZVAL:
	LD	L,E		;WE KNOW THAT NR_SCRCOL = 16 AND NR_PATTIL = 4
	LD	H,0		;ZROWSIZ = 127
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL		;HL = E * ZROWSIZ -> Y OFFSET
	PUSH	HL

	LD	L,D		;WE KNOW THAT NR_PATTIL = 4
	LD	H,0		;ZSTACKSIZ = 8
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL		;HL = D * ZSTACKSIZ -> X OFFSET
	POP	DE		;DE = Y OFFSET
	ADD	HL,DE		;HL = Y OFFSET + X OFFSET -> OFFSET
	LD	DE,ZBUFFER
	ADD	HL,DE		;HL = ADDRESS OF BUFFER[Y][X]
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ACTUAL TILE
;IT DOESN'T MODIFY THE DE VALUE

	CSEG

SETZVAL:LD	(Y.TILE),DE
	CALL	ADDRZVAL	;TAKE THE DIRECTION OF THE TILE STACK

Y.MASK:	LD	B,4
Y.LOOP:	LD	A,(HL)		;LOOK FOR A TILE WITHOUT ZVAL
	AND	1FH
	CP	NOZVALUE	;TODO: CHECK INCORRECT Z VALUE (LOWER VALUE)
	JR	Z,Y.SET
	INC	HL
	INC	HL
	DJNZ	Y.LOOP		;TODO: CHECK OVERRUN HERE

Y.SET:	PUSH	HL
	LD	DE,(Y.TILE)
	CALL	CALZVAL		;CALCULATE THE ZVALUE
	POP	HL
	LD	E,A		;WE HAVE FOUND THE LAST FREE POSITION ON THE
	LD	A,(MASK)	;TILE STACK, SO WE CAN USE IT
	RLCA			;THE MASK IS THE 3 UPPER BITS
	RLCA
	RLCA
	RLCA
	RLCA
	OR	E		;AND THE 5 LOWER BITS ARE THE Z VALUE
	LD	(HL),A
	INC	HL
	LD	A,(I.PATTERN)	;AND THE LAST BYTE IS THE PATTERN
	LD	(HL),A
	LD	DE,(Y.TILE)
	RET

	DSEG
Y.TILE:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES OF THE UPPER CORNER OF REGION
;	BC = SIZE
;	A = Z VALUE

	CSEG
	PUBLIC	REMAP

REMAP:	LD	(R.ZVALUE),A
	PUSH	DE
	PUSH	DE

	PUSH	BC
	LD	E,C
	LD	D,B
	CALL	XY2TILE			;CONVERT SIZE FROM XY SPACE TO
	LD	C,E			;TILE SPACE
	LD	B,D
	POP	HL
	CALL	ADJUSTBC

	POP	DE
	CALL	XY2TILE			;CONVERT COORDENATES FROM XY SPACE
	POP	HL			;TO TILE SPACE
	CALL	ADJUSTBC

	PUSH	DE
	CALL	ADDRZVAL		;POINT THE INITIAL TILE STACK
	POP	DE

	LD	A,(R.ZVALUE)		;Z VALUE IS INCREMENTED TO CORNER VALUE
	ADD	A,C
	LD	(R.ZVALUE),A

R.LOOPY:PUSH	BC			;AND NOW LOOP OVER THE Y
	PUSH	DE
	PUSH	HL

R.LOOPX:LD	(I.TILE),DE		;AND NOW LOOP OVER THE X
	PUSH	BC
	PUSH	HL
	CALL	R.STACK
	POP	HL			;POINT TO NEXT STACK
	LD	DE,ZSTACKSIZ
	ADD	HL,DE
	LD	DE,(I.TILE)		;INCREMENT X TILE POSITION
	INC	D
	POP	BC
	DJNZ	R.LOOPX

	LD	HL,R.ZVALUE		;DECREMENT Z VALUE
	DEC	(HL)
	POP	HL			;POINT HL TO NEXT ROW
	LD	DE,ZROWSIZ
	ADD	HL,DE
	POP	DE			;INCREMENT Y TILE POSITION
	INC	E
	POP	BC
	DEC	C
	JR	NZ,R.LOOPY
	RET
;

R.STACK:LD	A,(R.ZVALUE)
	LD	C,A
	LD	B,NR_PATTIL

S.LOOP:	LD	A,(HL)
	AND	1FH
	CP	NOZVALUE
	RET	Z			;RETURN WHEN EMPTY STACK
	CP	C
	RET	C			;RETURN WHEN Z VALUE IS SMALLER

	PUSH	HL
	PUSH	BC
	LD	A,(HL)			;DECRUNCH THE TILE INFORMATION
	AND	0E0H
	RLCA
	RLCA
	RLCA
	LD	(MASK),A		;MASK
	INC	HL
	LD	A,(HL)
	LD	(I.PATTERN),A		;PATTERN
	LD	DE,(I.TILE)
	CALL	DRAWTILE_		;AND REDRAW THE PATTERN
	POP	BC
	POP	HL

	INC	HL
	INC	HL
	DJNZ	S.LOOP
	RET

ADJUSTBC:
	LD	A,H
	AND	0FH			;IF HL IS NOT DIVISIBLE BY 16 AND 8
	JR	Z,A.1			;EACH ONE, THEN IT IS
	INC	B			;NEEDED INCREMENT THE SIZE OF THE
A.1:	LD	A,L			;REMAP REGION
	AND	07H
	RET	Z
	INC	C
	RET

	DSEG
R.ZVALUE:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
	PUBLIC  MAPCMD,METAPAT,TILE,TILEINC,PATTERN,ZVALUE
MASK:		DB	0		;ACTUAL TILE MASK. PARAMETER BY DEFAULT
TILE:		DW	0		;ACTUAL TILE. PARAMETER BY DEFAULT
PATTERN:	DB	0		;ACTUAL PATTERN. PARAMETER BY DEFAULT
TILEINC:	DW	0		;ACTUAL INCREMENT. PARAMETER BY DEFAULT
METAPAT:	DW	0		;SIZE OF META PATTERN
ZVALUE:		DB	0		;ACTUAL VALUE OF Z
MAPCMD:		DB	0		;MAPPER COMMAND
ZBUFFER:	DS	ZBUFFERSIZ	;Z BUFFER
I.TILE:		DW	0		;LOCAL COPY OF TILE
I.PATTERN:	DB	0		;LOCAL COPY OF PATTERN


