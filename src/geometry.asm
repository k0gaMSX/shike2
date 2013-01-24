	INCLUDE	KBD.INC
	INCLUDE GEOMETRY.INC
	INCLUDE BIOS.INC
	INCLUDE VDP.INC

GRIDCOLOR	EQU	6


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		(ACPAGE) = PAGE
	CSEG
	PUBLIC	GRID
	EXTRN	LINE,VDPSYNC

GRID:	LD	A,GRIDCOLOR
	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	IY,.GDATA

.GNEXT:	LD	D,(IY+0)		;LOAD NEXT LINE
	LD	E,(IY+1)
	LD	B,(IY+2)
	LD	C,(IY+3)

.GLINE:	PUSH	IY			;PAINT THE LINE
	PUSH	BC
	PUSH	DE
	CALL	LINE
	POP	DE
	POP	BC
	POP	IY

	LD	A,D			;CHECK IF WE HAVE TO PASS TO
	CP	(IY+4)			;NEXT ELEMENT OF THE TABLE
	JR	NZ,.GINC
	LD	A,E
	CP	(IY+5)
	JR	NZ,.GINC
	LD	A,B
	CP	(IY+6)
	JR	NZ,.GINC
	LD	A,C
	CP	(IY+7)
	JR	NZ,.GINC

	LD	DE,12			;PASS TO NEXT ELEMENT OF THE TABLE
	ADD	IY,DE
	LD	HL,.GDATAEND
	LD	E,IYL
	LD	D,IYU
	OR	A
	SBC	HL,DE
	JR	NZ,.GNEXT		;IS IT THE END?
	RET

.GINC:	LD	A,D			;USE THE INCREMENTS OF THE TABLE
	ADD	A,(IY+8)		;AND GET NEXT LINE
	LD	D,A
	LD	A,E
	ADD	A,(IY+9)
	LD	E,A
	LD	A,B
	ADD	A,(IY+10)
	LD	B,A
	LD	A,C
	ADD	A,(IY+11)
	LD	C,A
	JR	.GLINE


;	FROM   - X0   Y0  X1  Y1  - TO X2  Y2    X3  Y3   IX0 IY0 IX1 IY1
.GDATA:	DB	  0,  4,  255,131,      0, 84,  255,211,    0, 8,  0, 8
	DB	239,211,    0, 92,     15,211,    0,204,  -16, 0,  0, 8
	DB	  8,  0,  255,123,    248,  0,  255,  3,   16, 0,  0,-8
	DB	  0,  3,    7,  0,      0,123,  247,  0,    0, 8, 16, 0
	DB	  0,131,  255,  4,      0,211,  255, 84,    0, 8,  0, 8
	DB	 16,211,  255, 92,    240,211,  255,204,   16, 0,  0, 8
.GDATAEND:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = KEY
;OUTPUT: A = DIRECTION
;	 CF = 1 WHEN E IS NOT A DIRECTIONAL KEY

	CSEG
	PUBLIC	KEY2DIR

KEY2DIR:SUB	KB_RIGTH
	JR	C,K.NODIR
	CP	D.NODIR
	JR	NC,K.NODIR
	OR	A
	RET

K.NODIR:LD	A,D.NODIR
	OR	A
	SCF
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = DIRECTION
;	DE = COORDENATE
;OUTPUT:DE = COORDENATE AFTER MOVEMENT

	CSEG
	PUBLIC	MOVISO,MOVEUC

MOVISO:	LD	HL,M.ISO
	JR	MOVE

MOVEUC:	LD	HL,M.EUC

MOVE:	CP	D.NODIR
	RET	Z
	ADD	A,A
	ADD	A,L
	JR	NC,M.1
	INC	H
M.1:	LD	L,A

	LD	A,(HL)
	ADD	A,D
	LD	D,A

	INC	HL
	LD	A,(HL)
	ADD	A,E
	LD	E,A
	RET


;	        RIGTH   DOWN   UP     LEFT
M.ISO:	DB	1, 1, -1, 1,  1,-1,  -1,-1
M.EUC:	DB	1, 0,  0, 1,  0,-1,  -1, 0





