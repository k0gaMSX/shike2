	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC

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
;INPUT:		DE = INTIAL TILE POSITION
;		HL = CALLBACK FUNCTION
;		B = NUMBER OF ITERATIONS (NUMBER OF 'DOTS' IN THE LINE)
;		(ISODIR) = 0 -> POSITIVE (RIGTH), 1 -> NEGATIVE (LEFT)
	CSEG

ISOLINE:
	PUSH	BC			;LOOP OVER ISO X DRAWING AN ISO
	PUSH	DE			;HORIZONTAL LINE
	PUSH	HL

	LD	BC,L.RET
	PUSH	BC
	JP	(HL)			;GO TO CALLBACK FUNCTION

L.RET:	POP	HL
	POP	DE
	POP	BC

	LD	A,(ISODIR)
	OR	A
	JR	NZ,L.NEG
	DEC	E			;POSITIVE INCREMENT
	INC	D
	DJNZ	ISOLINE
	RET

L.NEG:	DEC	D			;NEGATIVE INCREMENT
	INC	E
	DJNZ	ISOLINE
	RET

	DSEG
ISODIR:	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:;	(TILEINC) = UPPER -> X INCREMENT, LOWER -> Y INCREMENT
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
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	BC,(TILEINC)
	LD	HL,DRAWTILE
	JR	ISORECT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILEINC) = UPPER -> X INCREMENT, LOWER -> Y INCREMENT
;		(TILE) = INITIAL TILE
;		(ISODIR) = 0 -> POSITIVE (RIGTH), 1 -> NEGATIVE (LEFT)
;		(ACPAGE) = PAGE

	CSEG
	PUBLIC	MARKREGION

MARKREGION:
	LD	A,DEFARG
	LD	(CMDARG),A
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
	CALL	ISOLINE			;SKIP THE LINE BECAUSE X=0
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
;		(VDPPAGE) = VDP SOURCE PAGE


	CSEG
	EXTRN	HMMM

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
	JP	HMMM

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
TILE:		DW	0		;ACTUAL TILE. PARAMETER BY DEFAULT
PATTERN:	DW	0		;ACTUAL PATTERN. PARAMETER BY DEFAULT
TILEINC:	DW	0		;ACTUAL INCREMENT. PARAMETER BY DEFAULT



