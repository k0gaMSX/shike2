
	INCLUDE	BIOS.INC
	INCLUDE	DATA.INC

CHARHEIGHT	EQU	4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITCHAR

INITCHAR:
	LD	HL,READY
	LD	(READY+CHAR.NEXT),HL
	LD	(READY+CHAR.PREV),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;	DE = HEAD OF LIST WHERE LINK

	CSEG

LINK:	LD	IYL,E			;IY = HEAD
	LD	IYU,D
	LD	L,E			;HL = HEAD
	LD	H,D
	LD	E,(IY+CHAR.NEXT)	;DE = HEAD->NEXT
	LD	D,(IY+CHAR.NEXT+1)
	LD	C,IXL
	LD	B,IXU			;BC = PTR

	LD	(IY+CHAR.NEXT),C	;HEAD->NEXT = PTR
	LD	(IY+CHAR.NEXT+1),B
	LD	IYL,E
	LD	IYU,D			;IY = HEAD->NEXT

	LD	(IX+CHAR.PREV),L
	LD	(IX+CHAR.PREV+1),H	;PTR->PREV = HEAD
	LD	(IX+CHAR.NEXT),E
	LD	(IX+CHAR.NEXT+1),D	;PTR->NEXT = HEAD->NEXT

	LD	(IY+CHAR.PREV),C
	LD	(IY+CHAR.PREV+1),B	;HEAD->NEXT->PREV = PTR
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

UNLINK:	LD	C,(IX+CHAR.PREV)
	LD	B,(IX+CHAR.PREV+1)	;BC = PTR->PREV
	LD	E,(IX+CHAR.NEXT)
	LD	D,(IX+CHAR.NEXT+1)	;DE = PTR->NEXT

	LD	IYL,C			;IY = PTR->PREV
	LD	IYU,B
	LD	(IY+CHAR.NEXT),E
	LD	(IY+CHAR.NEXT+1),D	;PTR->PREV->NEXT = PTR->NEXT

	LD	IYL,E			;IY = PTR->NEXT
	LD	IYU,D
	LD	(IY+CHAR.PREV),C
	LD	(IY+CHAR.PREV+1),B	;PTR->NEXT->PREV = PTR->PREV
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
	LD	HL,SETRDY
	CALL	MOVABLE
	POP	HL
	LD	(IX+CHAR.CONTROL),L
	LD	(IX+CHAR.CONTROL+1),H
	LD	DE,READY		;LINK IT IN READY LIST
	JP	LINK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	THINK
	EXTRN	PTRCALL

THINK:	PUSH	IX
	LD	DE,(READY+CHAR.NEXT)
	JR	T.ELOOP

T.LOOP:	LD	IXL,E
	LD	IXU,D
	LD	E,(IX+CHAR.NEXT)
	LD	D,(IX+CHAR.NEXT+1)
	PUSH	DE
	LD	L,(IX+CHAR.CONTROL)
	LD	H,(IX+CHAR.CONTROL+1)
	CALL	PTRCALL
	POP	DE

T.ELOOP:LD	HL,READY
	CALL	DCOMPR
	JR	NZ,T.LOOP

T.END:	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG

SETRDY:	LD	DE,READY
	JP	LINK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG
	PUBLIC	WALKER
	EXTRN	STEP

WALKER:	CALL	UNLINK
	LD	A,DRIGHT
	JP	STEP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
READY:	DS	CHAR.PREV+2		;CHARACTERS READY TO RUN

