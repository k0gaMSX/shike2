
	INCLUDE	DATA.INC

CHARHEIGHT	EQU	4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITCHAR

INITCHAR:
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;	E = PATTERN
;	BC = CONTROLLER FUNCTION

	CSEG
	PUBLIC	CHARACTER
	EXTRN	MOVABLE

CHARACTER:
	PUSH	BC
	LD	C,CHARHEIGHT
	LD	HL,WALKER
	CALL	MOVABLE
	POP	HL
	LD	(IX+CHAR.CONTROL),L
	LD	(IX+CHAR.CONTROL+1),H
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	WALKER
	EXTRN	STEP

WALKER:	LD	A,DRIGHT
	JP	STEP


