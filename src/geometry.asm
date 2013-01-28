	INCLUDE	KBD.INC
	INCLUDE GEOMETRY.INC
	INCLUDE BIOS.INC
	INCLUDE VDP.INC

GRIDCOLOR1	EQU	6
GRIDCOLOR2	EQU	8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		(ACPAGE) = PAGE
	CSEG
	PUBLIC	GRID
	EXTRN	LINE,VDPSYNC

GRID:	CALL	G.BASE

	LD	A,GRIDCOLOR2
	LD	(FORCLR),A
	LD	B,4
	LD	HL,G.DTOP

G.LOOP:	PUSH	BC			;PAINT THE SCREEN LIMITS
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	PUSH	HL
	CALL	LINE
	POP	HL
	POP	BC
	DJNZ	G.LOOP
	RET

G.BASE:	LD	A,GRIDCOLOR1
	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	IY,G.DBASE

G.NEXT:	LD	D,(IY+0)		;LOAD NEXT LINE
	LD	E,(IY+1)
	LD	B,(IY+2)
	LD	C,(IY+3)

G.LINE:	PUSH	IY			;PAINT THE LINE
	PUSH	BC
	PUSH	DE
	CALL	LINE
	POP	DE
	POP	BC
	POP	IY

	LD	A,D			;CHECK IF WE HAVE TO PASS TO
	CP	(IY+4)			;NEXT ELEMENT OF THE TABLE
	JR	NZ,G.INC
	LD	A,E
	CP	(IY+5)
	JR	NZ,G.INC
	LD	A,B
	CP	(IY+6)
	JR	NZ,G.INC
	LD	A,C
	CP	(IY+7)
	JR	NZ,G.INC

	LD	DE,12			;PASS TO NEXT ELEMENT OF THE TABLE
	ADD	IY,DE
	LD	HL,G.DTOP
	LD	E,IYL
	LD	D,IYU
	OR	A
	SBC	HL,DE
	JR	NZ,G.NEXT		;IS IT THE END?
	RET

G.INC:	LD	A,D			;USE THE INCREMENTS OF THE TABLE
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
	JR	G.LINE


;	FROM   - X0   Y0  X1  Y1  - TO X2  Y2    X3  Y3   IX0 IY0 IX1 IY1
G.DBASE:DB	  0,  4,  255,131,      0, 84,  255,211,    0, 8,  0, 8
	DB	239,211,    0, 92,     15,211,    0,204,  -16, 0,  0, 8
	DB	  8,  0,  255,123,    248,  0,  255,  3,   16, 0,  0,-8
	DB	  0,  3,    7,  0,      0,123,  247,  0,    0, 8, 16, 0
	DB	  0,131,  255,  4,      0,211,  255, 84,    0, 8,  0, 8
	DB	 16,211,  255, 92,    240,211,  255,204,   16, 0,  0, 8

;		X0  Y0   - X1  Y1
G.DTOP:	DB	127, 44,    0,107
	DB	0  ,108,  127,171
	DB	128,171,  255,108
	DB	255,107,  128, 44


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = KEY
;OUTPUT: A = DIRECTION
;	 CY = 1 WHEN E IS NOT A DIRECTIONAL KEY

	CSEG
	PUBLIC	KEY2DIR

KEY2DIR:SUB	KB_RIGTH
	JR	C,K.NODIR
	CP	D.NODIR
	JR	NC,K.NODIR
	OR	A
	RET

K.NODIR:LD	A,D.NODIR
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = WORLD COORDENATES
;	BC = SCREEN COORDENATES OF P1 (S(P1))
;OUTPUT:HL = X SCREEN COORDENATES (IT IS NEEDED 16 BIT FOR NEGATIVE NUMBERS)
;	DE = Y SCREEN COORDENATES (IT IS NEEDED 16 BIT FOR NEGATIVE NUMBERS)
;
;	   W                 S
;
;			     1
;			 --------
;	1----2		 |  / \ |
;	|    |		 | /   \|
;	|    |	->	3| \   /| 2
;	|    |		 |  \ / |
;	3----4		 --------
;			     4
;
; W(P1) = (0,0)
; D(P1->P2) = Xs + 4, Ys + 2 (RIGTH)
; D(P1->P3) = Xs - 4, Ys + 2 (DOWN)
; Xs = S(P1x) + (Xw-Yw)*4
; Ys = S(P1y) + (Xw+Yw)*2

	CSEG
	PUBLIC	WRLD2SCR

WRLD2SCR:
	PUSH	DE			;PUSH PARAMETER COORDENATES
	LD	L,D
	LD	D,0
	LD	H,D
	OR	A
	SBC	HL,DE			;HL = Xw-Yw
	ADD	HL,HL
	ADD	HL,HL			;HL = (Xw-Yw)*4
	LD	E,B
	ADD	HL,DE			;HL = (Xw-Yw)*4 + S(P1x) = Xs
	POP	DE			;POP PARAMETER COORDENATES

	PUSH	HL			;PUSH Xs
	LD	L,D
	LD	D,0
	LD	H,D
	ADD	HL,DE			;HL = Xw+Yw
	ADD	HL,HL			;HL = (Xw+Yw)*2
	LD	E,C
	ADD	HL,DE			;HL = (Xw+Yw)*2 + S(P1y) = Ys
	EX	DE,HL			;DE = Ys
	POP	HL			;HL = Xs
	RET


