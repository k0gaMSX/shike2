	INCLUDE	SHIKE2.INC
NR_PATTIL	EQU	4		;NUMBER OF PATTERNS BY TILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;THE TILES VALUES ARE CODED LIKE A SPARSE MATRIX, WHERE FOR EACH PATTERN
;POSITION (X,Y COORDENATES) WE HAVE A STACK OF PATTERNS & MASK AND THE VALUE
;OF THE Z COORDENATE OF THE TILE. CODED IN C:
;
;struct pattern {
;	unsigned char y;
;	unsigned char pattern;
;};
;
;struct pattern_stack {
;	struct pattern stack[NR_PATTIL];
;};
;
;struct tile_stack buffer[NR_SCRCOL][NR_SCRROW];
;


ZVALSIZ		EQU	2
ZSTACKSIZ	EQU	NR_PATTIL*ZVALSIZ
ZROWSIZ		EQU	NR_SCRCOL*ZSTACKSIZ
ZBUFFERSIZ	EQU	NR_SCRROW*ZROWSIZ

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = INPUT TILE
;OUTPUT:HL = POINTER TO THE TILE STACK ASSOCIATED TO THE INPUT TILE


	CSEG
	PUBLIC	ZSTACK
	EXTRN	MULTDEA

ZSTACK:	PUSH	DE
	LD	D,0
	LD	A,ZROWSIZ
	CALL	MULTDEA			;HL = YOFFSET
	POP	DE
	PUSH	HL
	LD	A,D
	LD	DE,ZSTACKSIZ
	CALL	MULTDEA			;HL = XOFFSET
	POP	DE			;DE = YOFFSET
	ADD	HL,DE			;HL = YOFFSET + XOFFSET
	LD	DE,ZBUFFER
	ADD	HL,DE			;HL = TILE STACK ADDRESS
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ACTUAL PATTERN
;	C  = Z VALUE
;	B  = PATTERN NUMBER
;OUTPUT:ZF = 1 WHEN ERROR

	CSEG
	PUBLIC	ADDZPAT

ADDZPAT:LD	(A.ZVAL),BC
	LD	(A.PAT),DE
	CALL	ZSTACK

	EX	DE,HL			;DE = STACK ADDRESS
	LD	C,0
A.LOOP:	CALL	ZVALUE
	JR	NZ,A.LOOP
	CP	255
	RET	NZ			;RETURN WHEN NO MORE PATTERNS IN STACK

	LD	BC,(A.ZVAL)		;HL = ZVAL POSITION
	LD	DE,(A.PAT)
	LD	A,C			;A = Z VALUE
	ADD	A,E			;A = Z VALUE + Y PATTERN POSITION
	ADD	A,A
	ADD	A,A
	ADD	A,A			;A = (ZVAL + Y)*8
	LD	(HL),A
	INC	HL
	LD	(HL),B			;B = PATTERN NUMBER
	RET

	DSEG
A.PAT:	DW	0			;PATTERN POSITION
A.ZVAL:	DB	0			;Z VALUE
A.NPAT:	DB	0			;PATTERN NUMBER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = TILE STACK
;	C = ZVALUE POSITION IN THE TILE STACK
;OUTPUT:ZF = 1 WHEN ERROR
;	D = PATTERN
;	A = E = Y
;	HL = POINT TO NEXT ELEMENT IN TILE STACK
;	B = INPUT VALUE
;	C = INPUT VALUE

	CSEG
	PUBLIC ZVALUE

ZVALUE:	LD	A,C
	CP	NR_PATTIL
	JR	C,Z.1
	XOR	A			;IF B >= NR_PATTIL THEN RETURN ERROR
	RET

Z.1:	EX	DE,HL
	LD	E,(HL)			;E = Y VALUE
	INC	HL
	LD	D,(HL)			;D = PATTERN
	INC	HL
	EX	DE,HL			;H = PATTERN, L = Y VALUE
	LD	A,L			;A = Y VALUE
	CP	255
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
ZBUFFER:	DS	ZBUFFERSIZ

