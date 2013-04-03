
	INCLUDE	BIOS.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDINIT
	EXTRN	MOUSE,MSCLR

EDINIT:	LD	A,1
	CALL	MOUSE
	JP	MSCLR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = DEFINITION OF GROUP OF LINES
;	C = COLOR

	CSEG
	PUBLIC	GLINES
	EXTRN	LINE

GLINES:	LD	IYL,E
	LD	IYU,D
	LD	A,C
	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A

G.NEXT:	LD	A,(IY+0)
	OR	A
	RET	Z
	LD	D,(IY+1)		;LOAD NEXT LINE
	LD	E,(IY+2)
	LD	B,(IY+3)
	LD	C,(IY+4)

G.LINE:	PUSH	AF
	PUSH	IY			;PAINT THE LINE
	PUSH	BC
	PUSH	DE
	CALL	LINE
	POP	DE
	POP	BC
	POP	IY

	LD	A,D			;USE THE INCREMENTS OF THE TABLE
	ADD	A,(IY+5)		;AND GET NEXT LINE
	LD	D,A
	LD	A,E
	ADD	A,(IY+6)
	LD	E,A
	LD	A,B
	ADD	A,(IY+7)
	LD	B,A
	LD	A,C
	ADD	A,(IY+8)
	LD	C,A
	POP	AF
	DEC	A
	JR	NZ,G.LINE

	LD	DE,9			;PASS TO NEXT ELEMENT OF THE TABLE
	ADD	IY,DE
	JR	G.NEXT

