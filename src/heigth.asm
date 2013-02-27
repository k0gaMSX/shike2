
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = POINTER TO HEIGTH BUFFER

	CSEG
	PUBLIC	RESETHEIGTH
	EXTRN	BZERO

RESETHEIGTH:
	EX	DE,HL
	LD	BC,HEIGTHSIZ
	JP	BZERO


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = POINTER TO THE OUTPUT BUFFER
;	DE = TILE POSITION OF LEFT-UP CORNER
;	BC = SIZE OF SQUARE
;	A = Z VALUE
;OUTPUT:HL = POINTER TO OUTPUT BUFFER AFTER CRUNCH

	CSEG
	EXTRN	PACK
	PUBLIC	H.CRUNCH

H.CRUNCH:
	LD	(HL),A
	INC	HL
	CALL	PACK
	LD	(HL),A
	LD	E,C
	LD	D,B
	CALL	PACK
	LD	(HL),A
	INC	HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = POINTER TO THE OUTPUT BUFFER
;OUTPUT:HL = POINTER TO OUTPUT BUFFER AFTER CRUNCH
;	DE = TILE POSITION OF LEFT-UP CORNER
;	BC = SIZE OF SQUARE
;	A = Z VALUE

	CSEG
	EXTRN	UNPACK

H.DECRUNCH:
	LD	A,(HL)
	INC	HL
	PUSH	AF
	LD	A,(HL)
	INC	HL
	CALL	UNPACK
	PUSH	DE
	LD	A,(HL)
	CALL	UNPACK
	LD	C,E
	LD	B,D
	POP	DE
	POP	AF
	RET


