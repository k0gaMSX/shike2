	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC


MASKY		EQU	128		;Y COORDENATE OF BITMAP MASKS
MASKTMP		EQU	00D4H		;XY COORDENATE FOR MASK OPERATIONS
MASKRGHTUP	EQU	0		;MASK RIGTH UP
MASKLEFTUP	EQU	1		;MASK LEFT UP
MASKRGHTDW	EQU	2		;MASK RIGTH DOWN
MASKLEFTDW	EQU	3		;MASK LEFT DOWN

MASKRGHTUP2	EQU	4		;MASK RIGTH UP, CUT THE RIGTH HALF
MASKLEFTUP2	EQU	5		;MASK LEFT UP, CUT THE RIGTH HALF
MASKRGHTDW2	EQU	6		;MASK RIGTH DOWN, CUT THE RIGTH HALF
MASKLEFTDW2	EQU	7		;MASK LEFT DOWN, CUT THE RIGTH HALF

MASKRGHTUP3	EQU	8		;MASK RIGTH UP, CUT THE LEFT HALF
MASKLEFTUP3	EQU	9		;MASK LEFT UP, CUT THE LEFT HALF
MASKRGHTDW3	EQU	10		;MASK RIGTH DOWN, CUT THE LEFT HALF
MASKLEFTDW3	EQU	11		;MASK LEFT DOWN, CUT THE LEFT HALF

MASKUP		EQU	12		;MASK UP
MASKHALFRGHT	EQU	13		;MASK, CUT RIGTH HALF
MASKHALFLEFT	EQU	14		;MASK, CUT LEFT HALF

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	NEXTISO

NEXTISO:LD	A,(ISOTYPE)		;PASS TO NEXT ISOMETRIC REGION TYPE
	CP	ISOYZ			;THIS FUNCTION IS ONLY NEEDED
	JR	Z,N.YZ			;BY THE EDITOR. EDITOR ONLY HAVE TO
	INC	A			;CALL IT AND SON'T WORRY ABOUT
	JR	N.STORE			;NUMBER OR CODIFICATIONS OF THEM
N.YZ:	LD	A,ISOXY
N.STORE:LD	(ISOTYPE),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = INTIAL TILE POSITION
;		HL = CALLBACK FUNCTION
;		B = NUMBER OF ITERATIONS (NUMBER OF 'DOTS' IN THE LINE)
;		(ISODIR) = 0 -> POSITIVE (RIGTH/DOWN)
;			   1 -> NEGATIVE (LEFT/UP)
	CSEG

ISOLINEV:
	EXX				;SAVE PARAMETERS
	LD	HL,I.ISOV
	JR	I.BODY

ISOLINEH:
	EXX
	LD	HL,I.ISOH

I.BODY:	LD	A,(ISODIR)
	AND	1
	ADD	A,A
	ADD	A,L
	LD	L,A
	JR	NC,I.1
	INC	H
I.1:	LD	A,(HL)
	LD	(I.INCX),A
	INC	HL
	LD	A,(HL)
	LD	(I.INCY),A
	EXX

I.TEST:	LD	A,B			;IF THE SIZE IS 0, THEN RETURN
	OR	B
	RET	Z

I.LOOP:	PUSH	BC			;LOOP OVER ISO X DRAWING AN
	PUSH	DE			;ISOMETRIC LINE
	PUSH	HL

	LD	BC,L.RET
	PUSH	BC
	JP	(HL)			;GO TO CALLBACK FUNCTION

L.RET:	POP	HL
	POP	DE
	POP	BC

	LD	A,(I.INCX)
	ADD	A,D
	LD	D,A
	LD	A,(I.INCY)
	ADD	A,E
	LD	E,A
	DJNZ	I.LOOP
	RET

;     ISODIR     0       1
;	       DX DY   DX DY
I.ISOV:	DB      1, 1,  -1,-1	;ISOMETRIC VERTICAL
I.ISOH:	DB      1,-1,  -1, 1	;ISOMETRIC HORIZONTAL

	DSEG
I.INCX:	DB	0
I.INCY:	DB	0


ISODIR:	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT-1, LOWER -> Y INCREMENT-1
;		(TILE) = INITIAL TILE
;		(PATTERN) = ACTUAL PATTERN
;		(ISODIR) = 0 -> POSITIVE (RIGTH), 1 -> NEGATIVE (LEFT)
;		(ACPAGE) = PAGE

	CSEG
	PUBLIC	DRAWREGION
	EXTRN	VDPPAGE

DRAWREGION:
	LD	A,DEFARG
	LD	(CMDARG),A
	XOR	A
	LD	(ISODIR),A
	LD	DE,(TILE)
	LD	(R.CORNERL),DE		;CALCULATE LEFT CORNER
	LD	BC,(TILEINC)

	LD	A,B
	OR	A
	RET	Z
	LD	A,C
	OR	A
	RET	Z

R.U1:	INC	D
	DEC	E
	DJNZ	R.U1
	LD	(R.CORNERU),DE		;CALCULATE UPPER RIGTH CORNER

	;
	;          U
	;         LXR
	;        LOIXR
	;       LOIIIXR
	;        IIIII
	;         III
	;          I
	;

	LD	DE,(R.CORNERU)		;DRAW TILE U
	LD	A,MASKUP
	LD	(MASK),A
	CALL	DRAWTILEM

	LD	BC,(TILEINC)		;DRAW TILES L
	LD	DE,(R.CORNERL)
	LD	HL,DRAWTILEM
	LD	A,MASKLEFTUP
	LD	(MASK),A
	CALL	ISOLINEH

	LD	DE,(R.CORNERU)		;DRAW TILES R
	INC	D
	INC	E
	LD	HL,DRAWTILEM
	LD	BC,(TILEINC-1)
	LD	A,MASKRGHTUP
	LD	(MASK),A
	CALL	ISOLINEV

	LD	BC,(TILEINC)		;DRAW TILES O
	DEC	B
	LD	DE,(R.CORNERL)
	INC	D
	LD	HL,DRAWTILE
	CALL	ISOLINEH

	LD	BC,(TILEINC)		;DRAW TILES X
	LD	DE,(R.CORNERU)
	INC	E
	LD	HL,DRAWTILE
	CALL	ISOLINEV

	LD	DE,(R.CORNERL)		;DRAW TILES I
	INC	E
	INC	D
	LD	BC,(TILEINC)
	DEC	B
	DEC	C
	LD	HL,DRAWTILE
	JP	ISORECT


	DSEG
R.CORNERU:	DW	0
R.CORNERL:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT-1, LOWER -> Y INCREMENT-1
;		(TILE) = INITIAL TILE
;		(ACPAGE) = PAGE

	CSEG
	PUBLIC	MARKREGION

MARKREGION:
	LD	A,DEFARG
	LD	(CMDARG),A
	XOR	A
	LD	(ISODIR),A
	LD	BC,(TILEINC)
	LD	HL,MARKTILE
	LD	DE,(TILE)
	;CONTINUE IN ISORECT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = CALLBACK FUNCTION
;		B = X INC (MINUS ONE)
;		C = Y INC (MINUS ONE)
;		DE = INITIAL TILE
;		(ISODIR) = 0 -> POSITIVE (RIGTH), 1 -> NEGATIVE (LEFT)
;
;WE HAVE TO PAINT LINES PARAREL TO THE SIDES, WITH THE SAME
;SIZE THAN THE SIDES, BUT ALSO WE HAVE TO PAINT LINES WITH DIFFERENT
;SIZE. TAKE A LOOK OF THE DRAW:
;         L
;        LOL
;	LOLOL
;        LOLOL
;         LOL
;          L
;SO THE FIRST CALL TO R.HELPER DRAWS THE L PATTERNS, WHILE SECOND CALL
;DRAWS THE O PATTERNS. YOU CAN SEE THAT THE SECOND CALL IS ONE PATTERN
;LESS IN X AND Y.

	CSEG
ISORECT:
	PUSH	DE
	PUSH	BC
	CALL	R.HELPER
	POP	BC
	POP	DE
	DEC	C
	DEC	B
	INC	D
	;CONTINUE IN HELPER

;INPUT:		HL = CALLBACK FUNCTION
;		B = X INC (MINUS ONE)
;		C = Y INC (MINUS ONE)
;		DE = INITIAL TILE
;		(ISODIR) = 0 -> POSITIVE (RIGTH), 1 -> NEGATIVE (LEFT)

R.HELPER:
	INC	C
	RET	Z			;RETURN BECAUSE Y=0
	INC	B
	RET	Z			;RETURN BECAUSE X=0

R.LOOP:	PUSH	BC
	PUSH	DE			;LOOP OVER Y AND DRAW PARAREL ISO LINES
	CALL	ISOLINEH
	POP	DE
	INC	E
	INC	D
	POP	BC
	DEC	C
	JR	NZ,R.LOOP
	RET

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(PATTERN) = PATTERN NUMBER
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT


	CSEG
	EXTRN	HMMM,VDPPAGE

DRAWTILE:
	CALL	ISVISIBLE
	RET	Z
	CALL	TILE2XY
	PUSH	DE
	LD	DE,(PATTERN)
	CALL	TILE2XY
	LD	L,E
	LD	H,D
	POP	DE
	LD	BC,1008H
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	JP	HMMM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(PATTERN) = PATTERN NUMBER
;		(MASK) = MASK USED IN THE PATTERN
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT

	CSEG
	EXTRN	LMMM,HMMM,VDPPAGE
DRAWTILEM:
	CALL	ISVISIBLE
	RET	Z
	PUSH	DE
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,(MASK)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,A
	LD	L,MASKY
	LD	DE,MASKTMP
	LD	BC,1008H
	CALL	HMMM			;COPY THE MASK TO THE TEMPORAL SPACE

	LD	DE,(PATTERN)		;TODO: MAYBE THIS SHOULD BE PATTERN NUM
	CALL	TILE2XY
	LD	A,LOGAND
	LD	(LOGOP),A
	LD	L,E
	LD	H,D
	LD	DE,MASKTMP
	LD	BC,1008H
	CALL	LMMM			;COPY THE PATTERN WITH AND OPERATION

	POP	DE
	CALL	TILE2XY
	LD	HL,MASKTMP
	LD	BC,1008H
	LD	A,(ACPAGE)
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	JP	LMMM			;COPY THE RESULT TO THE SCREEN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT

	CSEG
	EXTRN	LINE

MARKTILE:
	CALL	ISVISIBLE
	RET	Z
	CALL	TILE2XY			;TRANSFORM IT TO COORDINATES

	LD	A,LOGXOR
	LD	(LOGOP),A
	LD	A,MARKCOLOR
	LD	(FORCLR),A

	LD	A,D
	ADD	A,15
	LD	B,A
	LD	C,E
	PUSH	BC
	CALL	LINE			;LINE ORIGIN-RIGTH

	POP	DE
	LD	A,E
	ADD	A,7
	LD	C,A
	LD	B,D
	PUSH	BC
	CALL	LINE			;LINE RIGTH-UP/RIGTH

	POP	DE
	LD	A,D
	ADD	A,-15
	LD	B,A
	LD	C,E
	PUSH	BC
	CALL	LINE			;LINE UP/RIGTH-UP/LEFT

	POP	DE
	LD	A,E
	ADD	A,-7
	LD	C,A
	LD	B,D
	JP	LINE			;LINE UP/LEFT-ORIGIN



	DSEG
	PUBLIC	TILE,TILEINC,PATTERN
ISOTYPE:	DW	0		;ACTUAL ISO REGION. PARAMETER BY DEFAULT
MASK:		DW	0		;ACTUAL TILE MASK. PARAMETER BY DEFAULT
TILE:		DW	0		;ACTUAL TILE. PARAMETER BY DEFAULT
PATTERN:	DW	0		;ACTUAL PATTERN. PARAMETER BY DEFAULT
TILEINC:	DW	0		;ACTUAL INCREMENT. PARAMETER BY DEFAULT



