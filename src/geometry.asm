
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = DIRECTION
;	HL = X COORDENATE
;	DE = Y COORDENATE

	CSEG
	PUBLIC	MOV16ISO
	EXTRN	ADDAHL

MOV16ISO:
	CP	D.NODIR
	RET	Z
	PUSH	DE		;THIS FUNCTION IS USED FOR MOVING THINGS IN
	EX	DE,HL		;THE SCREEN, 1/4 OF TILE ON EACH FRAME.
	LD	HL,M16.D	;SCREEN COORDENATES ARE 16 BIT VALUES
	ADD	A,A		;AND THE INCREMENTS ARE DIFFERENT OF
	ADD	A,A		;1, SO WE CAN NOT USE THE USUAL MOVE FUNCTIONS
	CALL	ADDAHL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL

	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	POP	HL
	ADD	HL,BC
	EX	DE,HL
	RET

;	        RIGTH   DOWN     UP     LEFT
M16.D:	DW	2, 1,  -2, 1,   2,-1,  -2,-1

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
	POP	HL			;HL = Xs
	RET

	DSEG
W.CWRLD:	DW	0
W.P1X:		DW	0
W.P1Y:		DW	0

