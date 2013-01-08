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

MASKLEFT	EQU	15		;MASK LEFT
MASKRIGTH	EQU	16		;MASK RIGTH

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = INTIAL TILE POSITION
;		HL = CALLBACK FUNCTION
;		B = NUMBER OF ITERATIONS (NUMBER OF 'DOTS' IN THE LINE)
;		(METAPAT) = SIZE OF METAPAT (SAME FORMAT THAN TILEINC)
;		(ISODIR) = 0 -> POSITIVE (RIGTH/DOWN)
;			   1 -> NEGATIVE (LEFT/UP)
	CSEG

;INPUT:	A = 0,1,-1
;	B = VALUE
;OUTPUT:A = B*A


MULBY1:	OR	A
	JR	NZ,MUL.1
	LD	B,A
	RET

MUL.1:	AND	80H
	LD	A,B
	RET	Z
	NEG
	RET

EUCLINEV:
	EXX				;SAVE PARAMETERS
	LD	HL,I.EUCV
	JR	I.BODY

EUCLINEH:
	EXX				;SAVE PARAMETERS
	LD	HL,I.EUCH
	JR	I.BODY

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
I.1:	LD	BC,(METAPAT)
	INC	B
	INC	C
	LD	A,(HL)
	CALL	MULBY1
	LD	(I.INCX),A
	INC	HL
	LD	A,(HL)
	LD	B,C
	CALL	MULBY1
	LD	(I.INCY),A
	EXX

I.TEST:	LD	A,B			;IF THE SIZE IS 0 THEN RETURN
	OR	B
	RET	Z
	CP	-1			;IF THE SIZE IS -1, THEN RETURN
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
I.EUCV:	DB	0, 1,   0,-1	;EUCLIDEAN VERTICAL
I.EUCH:	DB	1, 0,  -1, 0	;EUCLIDEAN HORIZONTAL

	DSEG
I.INCX:	DB	0
I.INCY:	DB	0


ISODIR:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT-1, LOWER -> Y INCREMENT-1
;		(TILE) = INITIAL TILE
;		(I.PATTERN) = ACTUAL PATTERN
;		(ACPAGE) = PAGE

	CSEG
	EXTRN	VDPPAGE

DRAWREGION:
	LD	BC,(TILEINC)
	LD	A,B
	OR	A
	RET	Z
	LD	A,C
	OR	A
	RET	Z

	;WE ARE GOING TO CALCULATE SOME IMPORTANT POINTS THAT ALL THE CASES
	;WILL USE LATER
	;
	;	LEFT				RIGTH
	;           		TILE
	;	LEFTD				RIGTHD

	LD	DE,(TILE)
	LD	BC,(TILEINC)
D.R1:	DEC	E
	INC	D
	DJNZ	D.R1
	LD	(R.RIGTH),DE
	LD	A,E
	ADD	A,C
	LD	E,A
	LD	(R.RIGTHD),DE

	LD	DE,(TILE)
	LD	BC,(TILEINC)
D.R2:	DEC	E
	DEC	D
	DJNZ	D.R2
	LD	(R.LEFT),DE
	LD	A,E
	ADD	A,C
	LD	E,A
	LD	(R.LEFTD),DE

	LD	DE,(TILE)
	LD	A,E
	ADD	A,C
	LD	E,A
	LD	(R.DOWN),DE

	LD	BC,(TILEINC)
	LD	A,(ISOTYPE)
	CP	ISOXY
	JP	Z,DREGIONXY
	CP	ISOXZ
	JP	Z,DREGIONXZ
	;CONTINUE IN DREGIONYZ

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BC = (TILEINC)

	CSEG

DREGIONYZ:
	LD	A,1
	LD	(ISODIR),A

	;	J
	;	LU
	;	LIU
	;	LIIU
	;	KIIIX
	;	 DIIR
	;	  DIR
	;          DR
	;           Y

	LD	DE,(TILE)		;DRAW TILES U
	DEC	B
	DEC	D
	DEC	E
	LD	HL,DRAWTILEM
	LD	A,MASKRGHTUP
	LD	(MASK),A
	CALL	ISOLINEV

	LD	DE,(TILE)		;DRAW TILE X
	LD	A,MASKRGHTUP2
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	DE,(R.LEFT)		;DRAW TILE J
	LD	A,MASKRGHTUP3
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	BC,(TILEINC)		;DRAW TILES D
	LD	DE,(R.DOWN)
	DEC	B
	DEC	D
	DEC	E
	LD	HL,DRAWTILEM
	LD	A,MASKLEFTDW
	LD	(MASK),A
	CALL	ISOLINEV

	LD	DE,(R.LEFTD)		;DRAW TILE K
	LD	A,MASKLEFTDW2
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	DE,(R.DOWN)		;DRAW TILE Y
	LD	A,MASKLEFTDW3
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	BC,(TILEINC)		;DRAW TILES L
	LD	DE,(R.LEFTD)
	DEC	E
	DEC	C
	LD	B,C
	LD	HL,DRAWTILEM
	LD	A,MASKHALFLEFT
	LD	(MASK),A
	CALL	EUCLINEV

	LD	BC,(TILEINC)		;DRAW TILES R
	LD	DE,(R.DOWN)
	DEC	E
	DEC	C
	LD	B,C
	LD	HL,DRAWTILEM
	LD	A,MASKHALFRGHT
	LD	(MASK),A
	CALL	EUCLINEV

	LD	DE,(TILE)		;DRAW TILES I
	DEC	D
	LD	BC,(TILEINC)
	DEC	B
	DEC	B
	DEC	C
	DEC	C
	LD	HL,DRAWTILE
	JP	RECTANGLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BC = (TILEINC)

	CSEG

DREGIONXZ:
	XOR	A
	LD	(ISODIR),A

	;	   J
	;	  UR
	;	 UIR
	;	XIIR
	;	LIIK
	;	LID
	;	LD
	;	Y

	LD	DE,(TILE)		;DRAW TILES U
	DEC	B
	INC	D
	DEC	E
	LD	HL,DRAWTILEM
	LD	A,MASKLEFTUP
	LD	(MASK),A
	CALL	ISOLINEH

	LD	DE,(TILE)		;DRAW TILE X
	LD	A,MASKLEFTUP2
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	DE,(R.RIGTH)		;DRAW TILE J
	LD	A,MASKLEFTUP3
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	BC,(TILEINC)		;DRAW TILES D
	LD	DE,(R.DOWN)
	DEC	B
	INC	D
	DEC	E
	LD	HL,DRAWTILEM
	LD	A,MASKRGHTDW
	LD	(MASK),A
	CALL	ISOLINEH

	LD	DE,(R.RIGTHD)		;DRAW TILE K
	LD	A,MASKRGHTDW2
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	DE,(R.DOWN)		;DRAW TILE Y
	LD	A,MASKRGHTDW3
	LD	(MASK),A
	LD	HL,DRAWTILEM
	CALL	DRAWTILEM

	LD	BC,(TILEINC)		;DRAW TILES L
	LD	DE,(TILE)
	DEC	C
	LD	B,C
	INC	E
	LD	HL,DRAWTILEM
	LD	A,MASKHALFLEFT
	LD	(MASK),A
	CALL	EUCLINEV

	LD	BC,(TILEINC)		;DRAW TILES R
	LD	DE,(R.RIGTH)
	DEC	C
	LD	B,C
	INC	E
	LD	HL,DRAWTILEM
	LD	A,MASKHALFRGHT
	LD	(MASK),A
	CALL	EUCLINEV

	LD	DE,(TILE)		;DRAW TILES I
	INC	D
	LD	BC,(TILEINC)
	DEC	B
	DEC	B
	DEC	C
	DEC	C
	LD	HL,DRAWTILE
	JP	RECTANGLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BC = (TILEINC)

	CSEG

DREGIONXY:
	XOR	A
	LD	(ISODIR),A
	;
	;          U
	;         LXR
	;        LOIXR
	;       JOIIIXK
	;        IIIII
	;         III
	;          I
	;

	LD	DE,(R.RIGTH)		;DRAW TILE U
	LD	A,MASKUP
	LD	(MASK),A
	CALL	DRAWTILEM

	LD	DE,(R.RIGTH)		;DRAW TILE K
	LD	BC,(TILEINC)
	LD	B,C
D.R3:	INC	D
	INC	E
	DJNZ	D.R3
	LD	A,MASKRIGTH
	LD	(MASK),A
	CALL	DRAWTILEM

	LD	DE,(TILE)		;DRAW TILE J
	LD	A,MASKLEFT
	LD	(MASK),A
	CALL	DRAWTILEM

	LD	BC,(TILEINC)		;DRAW TILES L
	DEC	B
	LD	DE,(TILE)
	INC	D
	DEC	E
	LD	HL,DRAWTILEM
	LD	A,MASKLEFTUP
	LD	(MASK),A
	CALL	ISOLINEH

	LD	DE,(R.RIGTH)		;DRAW TILES R
	INC	D
	INC	E
	LD	BC,(TILEINC-1)
	DEC	B
	LD	HL,DRAWTILEM
	LD	A,MASKRGHTUP
	LD	(MASK),A
	CALL	ISOLINEV

	LD	BC,(TILEINC)		;DRAW TILES O
	DEC	B
	LD	DE,(TILE)
	INC	D
	LD	HL,DRAWTILE
	CALL	ISOLINEH

	LD	BC,(TILEINC)		;DRAW TILES X
	LD	B,C
	LD	DE,(R.RIGTH)
	INC	E
	LD	HL,DRAWTILE
	CALL	ISOLINEV

	LD	DE,(TILE)		;DRAW TILES I
	INC	E
	INC	D
	LD	BC,(TILEINC)
	DEC	B
	DEC	C
	LD	HL,DRAWTILE
	JP	RECTANGLE


	DSEG
R.DOWN:		DW	0
R.LEFT:		DW	0
R.LEFTD:	DW	0
R.RIGTH:	DW	0
R.RIGTHD:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT-1, LOWER -> Y INCREMENT-1
;		(TILE) = INITIAL TILE
;		(ACPAGE) = PAGE

	CSEG
	PUBLIC	MARKREGION

MARKREGION:
	LD	BC,(TILEINC)
	LD	HL,MARKTILE
	LD	DE,(TILE)
	;CONTINUE IN RECTANGLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = CALLBACK FUNCTION
;		B = X INC (MINUS ONE)
;		C = Y INC (MINUS ONE)
;		DE = INITIAL TILE
;NOTE: THIS FUNCTION MODIFY (ISODIR), SO BE CAREFUL

	CSEG

RECTANGLE:
	XOR	A
	LD	(ISODIR),A
	LD	A,(ISOTYPE)
	CP	ISOXY
	JR	Z,RECTXY
	CP	ISOXZ
	JR	Z,RECTXZ
	LD	A,1
	LD	(ISODIR),A
	;CONTINUE IN RECTXZ

;IN THE CASE OF XZ REGIONS AND YZ REGIONS THE CODE IS THE SAME, BECAUSE
;WE ONLY HAVE TO RUN OVER HORIZONTAL OR VERTICAL LINES.
;
;	X	   X
;	XX	  XX
;	XXX	 XXX
;	 XX	 XX
;	  X	 X

RECTXZ:	INC	B
	RET	Z
	INC	C
	RET	Z
E.LOOP:	PUSH	BC
	PUSH	DE			;LOOP OVER Y AND DRAW PARAREL ISO LINES
	LD	A,(ISOTYPE)
	CP	ISOXZ
	CALL	Z,ISOLINEH		;IF WE ARE IN PLANE XZ, HORIZONTAL LINES
	LD	A,(ISOTYPE)
	CP	ISOYZ
	CALL	Z,ISOLINEV		;IF WE ARE IN PLANE YZ, VERTICAL LINES
	POP	DE
	INC	E
	POP	BC
	DEC	C
	JR	NZ,E.LOOP
	RET


RECTXY:

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
;		(CMDARG) = VDP COMMAND ARGUMENT


	CSEG
	EXTRN	HMMM,VDPPAGE

DRAWTILE:
	CALL	ISVISIBLE
	RET	Z
	CALL	TILE2XY
	PUSH	DE
	LD	DE,(I.PATTERN-1)
	CALL	PAT2XY
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
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT
;		(METAPAT) = SIZE OF THE META PATTERN (SAME FORMAT OF TILEINC)

	CSEG

DRAWMETAT:
	LD	A,(PATTERN)
	LD	BC,(METAPAT)
	INC	B
	INC	C

DM.Y:	PUSH	BC
	PUSH	AF
	PUSH	DE

DM.X:	PUSH	BC			;PAINT ALL THE	PATTERNS IN THIS ROW
	PUSH	AF
	PUSH	DE
	LD	(I.PATTERN),A
	CALL	DRAWTILET
	POP	DE
	INC	D
	POP	AF
	INC	A
	POP	BC
	DJNZ	DM.X

	POP	DE
	INC	E
	POP	AF			;PASS TO THE NEXT PATTERN ROW
	ADD	A,16
	POP	BC
	DEC	C
	JR	NZ,DM.Y
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(I.PATTERN) = PATTERN NUMBER
;		(MASK) = MASK USED IN THE PATTERN
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT

	CSEG
	EXTRN	LMMM,VDPPAGE

DRAWTILET:
	CALL	TILE2XY			;DRAW A TILE WITH TRANSPARENT COLOR
	PUSH	DE
	LD	DE,(I.PATTERN-1)
	CALL	PAT2XY
	LD	L,E
	LD	H,D
	POP	DE

	LD	BC,1008H
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A
	JP	LMMM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		DE = TILE POSITION WE WANT MARK
;		(I.PATTERN) = PATTERN NUMBER
;		(MASK) = MASK USED IN THE PATTERN
;		(ACPAGE) = PAGE
;		(CMDARG) = VDP COMMAND ARGUMENT

	CSEG
	EXTRN	LMMM,HMMM,VDPPAGE
DRAWTILEM:
	CALL	ISVISIBLE
	RET	Z
	PUSH	DE

	LD	A,MASKPAGE
	LD	(VDPPAGE),A
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

	LD	DE,(I.PATTERN-1)
	CALL	PAT2XY
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
;INPUT:		(METAPAT) = UPPER -> X INCREMENT-1, LOWER -> Y INCREMENT-1
;		(PATTERN) = INITIAL TILE
;		(ACPAGE) = PAGE

	CSEG
	PUBLIC	MARKMETAPAT

MARKMETAPAT:
	XOR	A
	LD	(ISODIR),A
	LD	DE,(PATTERN-1)
	CALL	PAT2TILE
	LD	HL,MARKTILE
	LD	BC,(METAPAT)
	INC	B
	INC	C

MP.LOOP:PUSH	DE
	PUSH	BC
	CALL	EUCLINEH
	POP	BC
	POP	DE
	INC	E
	DEC	C
	JR	NZ,MP.LOOP
	RET

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