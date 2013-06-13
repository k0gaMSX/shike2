
	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE OBJECT
;	DE = POINT LOCATION
;	C = OBJECT ID

	CSEG
	PUBLIC	OBJECT
	EXTRN	MOVABLE,PLACE,ADDAHL

OBJECT:	PUSH	BC
	PUSH	DE
	LD	HL,OBJDEF
	LD	A,C
	CALL	ADDAHL
	LD	E,(HL)			;E = PATTERN
	INC	HL
	LD	C,(HL)			;C = SIZE
	LD	HL,0
	CALL	MOVABLE			;INIT MOVABLE

	POP	DE
	LD	C,DNODIR
	CALL	PLACE

	POP	BC
	LD	(IX+OBJECT.ID),C
	LD	(IX+OBJECT.OWNER),-1
	LD	E,IXL
	LD	D,IXU
	LD	(IX+OBJECT.NEXT),E
	LD	(IX+OBJECT.NEXT+1),D
	LD	(IX+OBJECT.PREV),E
	LD	(IX+OBJECT.PREV+1),D
	RET


OBJDEF:	DB	0,0			;PATTERN,SIZE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = OBJECT NUMBER

	CSEG
	PUBLIC	GETNOBJ
	EXTRN	MULTEA

GETNOBJ:LD	A,SIZOBJECT
	CALL	MULTEA
	LD	DE,OBJBUF
	ADD	HL,DE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
OBJBUF:	DS	NR_OBJECTS*SIZOBJECT

