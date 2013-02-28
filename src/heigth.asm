
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
	INC	HL
	DEC	B			;VALUES ALLOWED = 0 UNTIL 15
	DEC	C
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
	PUBLIC	H.DECRUNCH
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
	INC	HL
	CALL	UNPACK
	LD	C,E
	LD	B,D
	POP	DE
	POP	AF
	INC	B			;VALUES ALLOWED = 1 UNTIL 16
	INC	C
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEFT-UP CORNER
;	(H.MATRIX) = MATRIX POINTER
;OUTPUT:HL = ADDRESS OF THE BYTE WHICH CONSTAINS THE NIBBLE


	CSEG

ADDRSQR:PUSH	DE
	LD	L,E
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL		; HL = CORNERY * HEIGTHROWSIZ (YOFFSET)
	LD	E,D
	SRL	E
	LD	D,0
	ADD	HL,DE		; HL = YOFFSET + XOFFSET
	LD	DE,(H.MATRIX)
	ADD	HL,DE		; HL = MATRIX + YOFFSET
	POP	DE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = ADDRESS OF FIRST ELEMENT OF ROW
;	B = SIZE OF THE HEIGTH SQUARE
;	C = X COORDENATE OF ROW BEGINNING
;	A = Z VALUE

	CSEG

FILLROW:LD	(ROW.ZVAL),A
	LD	E,A
	RLCA
	RLCA
	RLCA
	RLCA
	OR	E
	LD	E,A
	BIT	0,C
	JR	Z,R.BYTES
	LD	A,(ROW.ZVAL)			;WRITE LOW NIBBLE FIRST ADDR
	RLD
	INC	HL
	DEC	B

R.BYTES:LD	A,B				;WRITE BOTH NIBBLES
	OR	A
	RET	Z				;CNT = 0? -> RETURN

R.LOOP:	LD	A,B
	CP	1
	JR	Z,R.LAST			;CNT = 1? -> WRITE LAST NIBBLE
	LD	(HL),E
	INC	HL
	DEC	B
	DEC	B
	JR	NZ,R.LOOP
	RET

R.LAST:	LD	A,(ROW.ZVAL)			;WRITE HIGH NIBBLE LAST ADDR
	RRD
	RET

	DSEG
ROW.ZVAL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEFT-UP CORNER
;	BC = SIZE OF SQUARE
;	A = Z VALUE

	CSEG

FILLSQR:CALL	ADDRSQR

S.LOOP:	PUSH	BC
	PUSH	DE
	PUSH	AF
	PUSH	HL
	LD	C,D			;C = XCOORDENATE,B = NUMBER OF ELEMENTS
	CALL	FILLROW			;HL = POINT TO 1ST BYTE, A = ZVAL
	POP	HL
	LD	DE,HEIGTHROWSIZ
	ADD	HL,DE			;HL = POINT TO NEXT ROW
	POP	AF
	POP	DE
	POP	BC
	DEC	C
	JR	NZ,S.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = INPUT HEIGTH BUFFER
;	BC = OUTPUT HEIGTH MATRIX

	CSEG
	PUBLIC	HMATRIX

HMATRIX:LD	(H.MATRIX),BC
	PUSH	DE
	LD	L,C
	LD	H,B
	LD	BC,HEIGTHMATRIXSIZ
	CALL	BZERO
	POP	DE

	EX	DE,HL
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
        LD	B,A

M.LOOP:	PUSH	BC
	CALL	H.DECRUNCH		;DECRUNCH EACH COMMAND
	PUSH	HL
	CALL	FILLSQR			;FILL SQUARE
	POP	HL
	POP	BC
	DJNZ	M.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = TILE POSITION
;	BC = MATRIX POINTER

	CSEG
	PUBLIC	HEIGTH

HEIGTH:	LD	(H.MATRIX),BC
	CALL	ADDRSQR
	LD	A,(HL)
	BIT	0,D			;ODD OR EVEN X COORDENATE?
	JR	Z,H.UPPER
	AND	0FH
	RET

H.UPPER:AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG

H.MATRIX:	DW	0	;LOCAL COPY OF POINTER TO ACTUAL MATRIX

