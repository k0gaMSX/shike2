
	INCLUDE BIOS.INC
	INCLUDE SHIKE2.INC
	INCLUDE KBD.INC
	INCLUDE GEOMETRY.INC

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = DIRECTION
;	C = COUNT
;OUTPUT:DE = Y INCREMENT
;	BC = X INCREMENT

	CSEG
	PUBLIC	ISOINC

ISOINC:	LD	A,E			;THIS FUNCTION RETURNS THE ISOMETRIC
	ADD	A,A			;INCREMENT DUE TO A NUMBER OF MINIMAL
	ADD	A,A			;STEPS (2X1) IN A DIRECTION
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	A,C
	ADD	A,A
	ADD	A,A
	ADD	A,E
	LD	E,A
	LD	D,0
	LD	HL,I.DATA
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	RET

I.DATA:	DW	 2, 1,	 4, 2,	 6, 3,	 8, 4	;RIGTH
	DW	-2, 1,	-4, 2,	-6, 3,	-8, 4	;DOWN
	DW	 2,-1,	 4,-2,	 6,-3,	 8,-4	;UP
	DW	-2,-1,	-4,-2,	-6,-3,	-8,-4	;LEFT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = DIRECTION
;	DE = COORDENATE
;OUTPUT:DE = COORDENATE AFTER MOVEMENT

	CSEG
	PUBLIC	MOVISO,MOVEUC,MOVIEUC,MOVIYEUC
	EXTRN	ADDAHL

MOVISO:	LD	HL,M.ISO
	JR	MOVE

MOVIEUC:LD	HL,M.IEUC
	JR	MOVE

MOVIYEUC:
	LD	HL,M.IYEUC
	JR	MOVE

MOVEUC:	LD	HL,M.EUC

MOVE:	CP	D.NODIR
	RET	Z
	ADD	A,A
	CALL	ADDAHL
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
M.IEUC:	DB     -1, 0,  0,-1,  0, 1,   1, 0
M.IYEUC:DB	1, 0,  0,-1,  0, 1,  -1, 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ORIGIN X,Y
;	BC = ORIGIN ROOM
;	A = DIRECTION
;OUTPUT:DE = DESTINATION XY
;	BC = ORIGIN ROOM

	CSEG
	PUBLIC	NEXTPOINT

NEXTPOINT:
	PUSH	BC
	CALL	MOVEUC
	POP	BC

	LD	A,D
N.RIGTH:CP	MAXISOX
	JR	NZ,N.LEFT
	LD	D,0
	INC	B
	RET

N.LEFT:	CP	-1
	JR	NZ,N.DOWN
	LD	D,MAXISOX-1
	DEC	B
	RET

N.DOWN:	LD	A,E
	CP	MAXISOY
	JR	NZ,N.UP
	LD	E,0
	INC	C
	RET

N.UP:	CP	-1
	RET	NZ			;IF WE RETRUN HERE IT MEANS A BUG
	LD	E,MAXISOY-1
	DEC	C
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = WORLD COORDENATES
;	A  = Z WORLD COORDENATE
;	DE = X SCREEN COORDENATES OF P1 (S(P1x)) (16 BIT FOR NEGATIVE NUMBERS)
;	BC = Y SCREEN COORDENATES OF P1 (S(P1y)) (16 BIT FOR NEGATIVE NUMBERS)
;OUTPUT:HL = X SCREEN COORDENATES (16 BIT FOR NEGATIVE NUMBERS)
;	DE = Y SCREEN COORDENATES (16 BIT FOR NEGATIVE NUMBERS)
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
; D(P1->P2) = Xs + 8, Ys + 4 (RIGTH)
; D(P1->P3) = Xs - 8, Ys + 4 (DOWN)
; Xs = S(P1x) + (Xw-Yw)*16
; Ys = S(P1y) + (Xw+Yw)*8

	CSEG
	PUBLIC	WRLD2SCR

WRLD2SCR:
	LD	(W.ZVAL),A
	LD	(W.CWRLD),HL
	LD	(W.P1X),DE
	LD	(W.P1Y),BC

	LD	D,0
	LD	E,L
	LD	L,H
	LD	H,D
	OR	A
	SBC	HL,DE			;HL = Xw-Yw
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			;HL = (Xw-Yw)*8
	LD	DE,(W.P1X)
	ADD	HL,DE			;HL = (Xw-Yw)*8 + S(P1x) = Xs
	PUSH	HL			;PUSH Xs

	LD	HL,(W.CWRLD)
	LD	D,0
	LD	E,L
	LD	L,H
	LD	H,D
	ADD	HL,DE			;HL = Xw+Yw
	ADD	HL,HL
	ADD	HL,HL			;HL = (Xw+Yw)*4
	LD	DE,(W.P1Y)
	ADD	HL,DE			;HL = (Xw+Yw)*4 + S(P1y) = Ys
	EX	DE,HL			;DE = Ys

	LD	A,(W.ZVAL)
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			;HL = Zw*8
	EX	DE,HL			;HL = Ys, DE = Zw*8
	OR	A
	SBC	HL,DE			;HL = Ys - Zw*8 (Y CORRECTION DUE TO Z)
	EX	DE,HL			;DE = Ys - Zw*8
	POP	HL			;HL = Xs
	RET

	DSEG
W.ZVAL:		DB	0
W.CWRLD:	DW	0
W.P1X:		DW	0
W.P1Y:		DW	0

