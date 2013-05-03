
	INCLUDE	BIOS.INC
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

	CSEG
	PUBLIC	ZVALINIT
	EXTRN	BZERO

ZVALINIT:
	LD	HL,ZBUFFER
	LD	BC,ZBUFFERSIZ
	JP	BZERO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = INPUT TILE
;OUTPUT:HL = POINTER TO THE TILE STACK ASSOCIATED TO THE INPUT TILE


	CSEG
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
	CALL	ZSTACK

	LD	C,0
A.LOOP:	EX	DE,HL			;DE = STACK ADDRESS
	CALL	ZVALUE
	RET	Z			;Z = 1 MEANS END OF STACK
	LD	A,D			;PATTERN 0 MEANS NO USED
	OR	A
	JR	NZ,A.LOOP

	DEC	HL
	DEC	HL
	LD	BC,(A.ZVAL)		;HL = ZVAL POSITION
	LD	(HL),C
	INC	HL
	LD	(HL),B			;B = PATTERN NUMBER
	RET

	DSEG
A.ZVAL:	DB	0			;Z VALUE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = TILE STACK
;	C = ZVALUE POSITION IN THE TILE STACK
;OUTPUT:ZF = 1 WHEN ERROR
;	D = PATTERN
;	E = Y
;	HL = POINT TO NEXT ELEMENT IN TILE STACK
;	B = INPUT VALUE
;	C = INPUT VALUE + 1

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
	INC	C			;SET Z FLAG = 0
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES
;	HL = BASE COORDENATE
;	B = X SIZE
;	C = Y SIZE

	CSEG
	PUBLIC	REMAP
	EXTRN	PAT2XY,XY2PAT,VDPPAGE

REMAP:	LD	A,LOGTIMP		;SET THE DATA FOR THE VDP COMMANDS
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A

	PUSH	DE
	LD	(R.BASE),HL
	LD	E,C			;DE = REGION SIZE
	LD	D,B
	CALL	XY2PAT
	LD	C,L			;BC = REGION SIZE IN PATTERN UNITS
	LD	B,H
	CALL	ADJUSTBC		;ADJUST BC DUE TO REGION SIZE

	POP	DE
	CALL	ADJUSTBC		;ADJUST BC DUE TO ORIGIN POINT
	CALL	XY2PAT
	EX	DE,HL			;DE = PATTERN POSITION
	CALL	PAT2XY			;HL = PATTERN COORDENATES

R.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	HL
	PUSH	DE
	LD	B,C
R.LOOPY:PUSH	BC			;LOOP OVER Y
	PUSH	HL
	PUSH	DE
	CALL	STACK
	POP	DE
	INC	E
	POP	HL
	LD	A,L
	ADD	A,8
	LD	L,A
	POP	BC
	DJNZ	R.LOOPY			;END OF LOOPY

	POP	DE
	INC	D
	POP	HL
	LD	A,H
	ADD	A,16
	LD	H,A
	POP	BC
	DJNZ	R.LOOPX			;END OF LOOPX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = PATTERN POSITION
;	HL = PATTERN BASE COORDENATES
;	(R.BASE) = BASE POSITION

	CSEG
	EXTRN	PNUM2XY,PAT2XY,LMMM

STACK:	LD	A,NR_SCRROW-1		;IS IT VISIBLE?
	CP	E
	RET	C
	LD	A,NR_SCRCOL-1
	CP	E
	RET	C

	LD	(R.COOR),HL		;SAVE PATTERN BASE COORDENATES
	CALL	ZSTACK			;HL = STACK ADDRESS
	LD	C,0
S.LOOP:	EX	DE,HL			;DE = STACK ADDRESS
	CALL	ZVALUE			;HL = NEXT ELEMENT IN STACK ADDRESS
	RET	Z			;D = PATTERN
	LD	A,D			;E = Z VALUE
	OR	A
	RET	Z

	LD	A,E
	EXX
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A			;DE = ZVAL*8
	LD	D,0
	LD	HL,(R.COOR)
	LD	H,0			;HL = PATTERN BASE Y COORDENATE
	ADD	HL,DE
	EX	DE,HL			;DE = PATTERN ZBASE Y COORDENATE
	LD	HL,(R.BASE)		;HL = MOB BASE Y COORDENATE
	OR	A
	SBC	HL,DE
	EXX
	JR	NC,S.LOOP		;PY < MY => DON'T REPAINT

	PUSH	BC
	PUSH	HL
	LD	E,D
	CALL	PNUM2XY			;HL = ORIGIN COORDENATES
	LD	DE,(R.COOR)		;DE = PATTERN BASE COORDENATES
	LD	BC,1008H
	CALL	LMMM
	POP	HL
	POP	BC
	JR	S.LOOP

	DSEG
R.BASE:	DW	0
R.COOR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = INPUT VALUE
;	BC = COUNT
;OUTPUT:DE = INPUT VALUE (IT IS NOT MODIFIED)
;	BC = COUNT AFTER CHECKING

	CSEG

ADJUSTBC:
	LD	A,D
	AND	0FH			;IF DE IS NOT DIVISIBLE BY 16 AND 8
	JR	Z,A.1			;EACH ONE, THEN IT IS
	INC	B			;NEEDED INCREMENT THE SIZE OF THE
A.1:	LD	A,E			;REMAP REGION
	AND	07H
	RET	Z
	INC	C
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
ZBUFFER:	DS	ZBUFFERSIZ

