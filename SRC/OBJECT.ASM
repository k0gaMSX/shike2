
	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC

OBJPAT	EQU	4*4*3+8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	OBJINIT
	EXTRN	OBJDATA

OBJINIT:PUSH	IX
	LD	B,NR_OBJECTS
	LD	IY,OBJDATA
	LD	IX,OBJBUF

I.LOOP:	PUSH	BC
	PUSH	IY
	LD	E,IYL
	LD	D,IYU
	LD	C,(IY+OINFO.ID)
	CALL	OBJECT
	LD	DE,SIZOBJECT
	ADD	IX,DE
	POP	IY
	LD	DE,SIZOINFO
	ADD	IY,DE
	POP	BC
	DJNZ	I.LOOP
	POP	IX
	RET

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
	ADD	A,A
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


OBJDEF:	DB	OBJPAT,1		;PATTERN,SIZE
	DB	OBJPAT-1,2		;PATTERN,SIZE
	DB	OBJPAT+1,1
	DB	OBJPAT+2,0
	DB	OBJPAT+3,1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO OBJECT
;	E = OBJECT ID

	CSEG
	PUBLIC	SETOBJID

SETOBJID:
	LD	(IX+OBJECT.ID),E
	LD	A,E
	ADD	A,A
	LD	HL,OBJDEF
	CALL	ADDAHL
	LD	A,(HL)
	LD	(IX+MOV.PAT),A
	INC	HL
	LD	A,(HL)
	LD	(IX+MOV.ZSIZ),A
	RET

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