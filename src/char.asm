
	INCLUDE	DATA.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITCHAR

INITCHAR:
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;	DE = CONTROLLER FUNCTION

	CSEG
	PUBLIC	CHAR
	EXTRN	MOVABLE

CHAR:	PUSH	DE
	CALL	MOVABLE
	POP	DE
	LD	(IX+CHAR.CONTROL),E
	LD	(IX+CHAR.CONTROL+1),D
	RET



