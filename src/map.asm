

	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	LEVEL.INC

NR_RMAPS	EQU	7	;NUMBER OF MAPS RENDERED,4 DIR+2 DIAG+CENTER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEVEL LOCATION
;	BC = ROOM LOCATION

	CSEG
	PUBLIC	MAP
	EXTRN	ZVALINIT,ARYHL,ARYDE

MAP:	LD	(P.LEVEL),DE
	LD	(P.ROOM),BC
	CALL	ZVALINIT
	XOR	A

P.LOOP:	PUSH	AF
	PUSH	AF
	LD	HL,POFFSET
	CALL	ARYHL
	LD	C,L
	LD	B,H
	POP	AF
	LD	HL,PINC
	CALL	ARYHL
	LD	DE,(P.ROOM)
	LD	A,L
	ADD	A,E
	LD	E,A
	LD	A,H
	ADD	A,D
	LD	D,A
	LD	HL,(P.LEVEL)
	CALL	MAPROOM
	POP	AF
	INC	A
	CP	NR_RMAPS
	JR	NZ,P.LOOP
	RET


POFFSET:DB	CENTRAL.P1Y-16,CENTRAL.P1X	;LEFT-UP
	DB	CENTRAL.P1Y-8 ,CENTRAL.P1X-8	;LEFT
	DB	CENTRAL.P1Y-8 ,CENTRAL.P1X+8	;UP
	DB	CENTRAL.P1Y   ,CENTRAL.P1X	;CENTRAL
	DB	CENTRAL.P1Y+8 ,CENTRAL.P1X-8	;DOWN
	DB	CENTRAL.P1Y+8 ,CENTRAL.P1X+8	;RIGHT
	DB	CENTRAL.P1Y+16,CENTRAL.P1X	;RIGHT DOWN

PINC:	DB	-1,-1				;LEFT UP
	DB	 0,-1				;LEFT
	DB	-1, 0				;UP
	DB	 0, 0				;CENTRAL
	DB	 1, 0				;DOWN
	DB	 0, 1				;RIGHT
	DB	 1, 1				;RIGHT DOWN

	DSEG
P.LEVEL:DW	0
P.ROOM:	DW	0
P.CNT:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = LEVEL LOCATION
;	DE = ROOM LOCATION
;	BC = SCREEN OFFSET

	CSEG
	EXTRN	CARTPAGE,PTRHL

MAPROOM:LD	(R.LVL),HL
	LD	(R.ROOM),DE
	LD	(R.OFF),BC
	XOR	A

R.LOOP:	LD	(R.HGTH),A
	LD	E,LEVELPAGE
	CALL	CARTPAGE
	LD	DE,(R.LVL)
	LD	BC,(R.ROOM)
	LD	A,(R.HGTH)
	CALL	GETROOM
	JR	Z,R.LOOP
	CALL	PTRHL
	EX	DE,HL
	LD	BC,(R.OFF)
	LD	A,(R.HGTH)
	CALL	MAPMAP
	RET	Z

R.ELOOP:LD	A,(R.HGTH)
	INC	A
	CP	NR_HEIGHTS
	JR	NZ,R.LOOP
	RET

	DSEG

R.HGTH:	DB	0
R.LVL:	DW	0
R.ROOM:	DW	0
R.OFF:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = MAP NUMBER
;	BC = OFFSET
;	A = HEIGHT
;OUTPUT:Z=1 WHEN NO VALID MAP


	CSEG
	PUBLIC	MAPMAP

MAPMAP:	LD	(M.HGHT),A
	LD	(M.OFFS),BC
	LD	(M.MNUM),DE
	LD	A,D
	OR	E
	RET	Z			;0 IS EMPTY MAP, RETURN
	CALL	MAPFLOOR
	CALL	MAPTILE
	OR	1
	RET

	DSEG
M.MNUM:	DW	0
M.OFFS:	DW	0
M.HGHT:	DB	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = PATTERN NUMBER
;OUTPUT:HL = COORDENATES OF THE PATTERN

	CSEG
	PUBLIC	PNUM2XY

PNUM2XY:LD	A,E			;PATTERN NUMBER TO XY
	AND	0F0H
	RRCA
	LD	L,A

	LD	A,E
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	H,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = XY COORDENAYES
;OUTPUT:DE = TILE COORDENATES

	CSEG
	PUBLIC	PAT2XY

PAT2XY:	LD	A,E			;Y = YPATTERN*8
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	L,A
	LD	A,D			;X = XPATTERN*16
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	H,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = XY COORDENAYES
;OUTPUT:HL = TILE COORDENATES

	CSEG
	PUBLIC	XY2PAT

XY2PAT:	LD	A,E
	AND	0F8H
	RRCA
	RRCA
	RRCA
	LD	L,A
	LD	A,D
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	LD	H,A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = PATTERN STACK
;	BC = SCREEN COORDINATES

	CSEG
	EXTRN	VDPPAGE,LMMM,ADDZPAT

MAPSTACK:
	BIT	7,B			;CHECK IF THE SCREEN POSITION IS
	RET	NZ			;NEGATIVE
	BIT	7,C
	RET	NZ
	LD	A,NR_SCRCOL		;OR THE X POSITION IS OUTSIDE
	CP	B
	RET	C
	LD	A,NR_SCRROW		;OR THE Y POSITION IS OUTSIDE
	CP	C
	RET	C

	PUSH	DE
	LD	(S.PAT),BC
	LD	E,C
	LD	D,B
	CALL	PAT2XY
	LD	(S.COORD),HL
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A

	POP	HL
	LD	B,NR_LAYERS
S.LOOP:	LD	A,(HL)			;0 MARKS THE END OF A TILE STACK
	OR	A
	RET	Z

	PUSH	HL
	PUSH	BC

	PUSH	AF
	LD	E,A
	CALL	PNUM2XY			;TRANSFORM THE PATTER NUMBER TO XY
	LD	DE,(S.COORD)
	LD	BC,1008H
	CALL	LMMM			;AND COPY THE PATTERN TO THE DESTINE
	LD	DE,(S.PAT)		;DE = PATTERN COORDENATES
	POP	BC			;B = PATTERN NUMBER
	LD	A,(S.ZVAL)
	LD	C,A			;C = ZVAL
	CALL	ADDZPAT

	POP	BC
	POP	HL
	INC	HL
	DJNZ	S.LOOP
	RET

	DSEG
S.PAT:	DW	0
S.COORD:DW	0
S.ZVAL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN POSITION
;	A = FLOOR NUMBER
;	(M.HGHT) = HEIGHT LEVEL

	CSEG

FLOORFUN:
	PUSH	DE
	LD	E,A
	CALL	GETFLOOR
	EX	DE,HL			;DE = FLOOR DEFINITION ADDRESS
	POP	BC			;BC = SCREEN POSITION
	LD	A,(M.HGHT)
	ADD	A,A
	ADD	A,A
	LD	(S.ZVAL),A		;ZVAL IS CONSTANT IN FLOORS
	LD	A,FLOORYSIZ

F.LOOPI:PUSH	AF			;LOOP OVER ALL THE ROWS OF THE STACK
	PUSH	DE
	PUSH	BC
	CALL	MAPSTACK
	POP	BC			;INCREMENT Y
	INC	C
	POP	DE
	LD	HL,NR_LAYERS
	ADD	HL,DE
	EX	DE,HL			;DE POINT TO NEXT ROW
	POP	AF
	DEC	A			;CONTROL NUMBER OF ITERATIONS
	JR	NZ,F.LOOPI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN POSITION
;	A = TILE NUMBER

	CSEG

TILEFUN:PUSH	DE
	LD	E,A
	CALL	GETTILE
	LD	DE,TILE.MAP
	ADD	HL,DE
	EX	DE,HL			;DE = TILE DEFINITION ADDRESS
	POP	BC			;BC = SCREEN POSITION
	LD	A,(M.HGHT)
	ADD	A,A
	ADD	A,A
	ADD	A,TILEYSIZ-1
	LD	(S.ZVAL),A		;ZVAL IS NOT CONSTANT IN TILES
	LD	A,TILEYSIZ

T.LOOPI:PUSH	AF			;LOOP OVER ALL THE ROWS OF THE STACK
	PUSH	DE
	PUSH	BC
	CALL	MAPSTACK
	LD	HL,S.ZVAL		;INCREMENT Z VALUE
	DEC	(HL)
	POP	BC			;INCREMENT Y
	INC	C
	POP	DE
	LD	HL,NR_LAYERS
	ADD	HL,DE
	EX	DE,HL			;DE POINT TO NEXT ROW
	POP	AF
	DEC	A			;CONTROL NUMBER OF ITERATIONS
	JR	NZ,T.LOOPI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(M.MNUM) = FLOOR MAP NUMBER
;	(M.OFFS) = SCREEN OFFSET
;	(M.HGHT) = HEIGHT

	CSEG
	EXTRN	CARTPAGE

MAPTILE:LD	BC,(M.OFFS)		;CALCULATE INITIAL POSITION
	LD	A,C
	SUB	TILEYSIZ-2
	LD	C,A
	LD	(M.POS),BC
	LD	HL,TILEFUN
	LD	(M.FUN),HL
	LD	DE,(M.MNUM)
	CALL	GETTMAP			;HL = FLOOR MAP ADDRESS
	JR	MAP.AUX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(M.MNUM) = FLOOR MAP NUMBER
;	(M.OFFS) = SCREEN OFFSET
;	(M.HGHT) = HEIGHT

	CSEG
	EXTRN	CARTPAGE

MAPFLOOR:
	LD	BC,(M.OFFS)
	LD	(M.POS),BC		;SAVE INITIAL PATTERN
	LD	HL,FLOORFUN
	LD	(M.FUN),HL
	LD	DE,(M.MNUM)
	CALL	GETFMAP			;HL = FLOOR MAP ADDRESS

	;CONTINUE IN MAP.AUX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = MAP POINTER
;	(M.POS) = INITIAL PATTERN POSITION
;	(M.FUN) = CALLBACK FUNCTION
;	(M.HGHT) = HEIGHT

	CSEG
	EXTRN	PTRCALL

MAP.AUX:LD	DE,M.MAP
	LD	BC,MAPXSIZ*MAPYSIZ
	LDIR				;COPY THE MAP TO LOCAL COPY
	LD	E,LEVELPAGE		;SET LEVEL DEFINITION PAGE
	CALL	CARTPAGE

	LD	DE,(M.POS)		;DE = INITIAL POSITION
	LD	A,(M.HGHT)		;HEIGHT ADJUST
	ADD	A,A
	ADD	A,A
	LD	C,A
	LD	A,E
	SUB	C
	LD	E,A
	LD	HL,M.MAP
	LD	B,MAPYSIZ
M.LOOPY:PUSH	BC			;LOOP OVER X
	PUSH	DE

	LD	B,MAPXSIZ
M.LOOPX:PUSH	BC			;LOOP OVER Y
	PUSH	DE
	PUSH	HL

	LD	A,(HL)
	OR	A			;0 MEANS EMPTY ELEMENT
	LD	HL,(M.FUN)
	CALL	NZ,PTRCALL

M.ENDX:	POP	HL
	INC	HL
	POP	DE
	INC	D
	INC	E
	POP	BC
	DJNZ	M.LOOPX			;END OF X LOOP

	POP	DE
	DEC	D
	INC	E
	POP	BC
	DJNZ	M.LOOPY			;END OF Y LOOP
	RET

	DSEG
M.MAP:	DS	MAPXSIZ*MAPYSIZ
M.POS:	DW	0
M.FUN:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = MAP NUMBER
;OUTPUT:A = CARTRIDGE PAGE
;	HL = OFFSET

	CSEG
	PUBLIC	GETFMAP
	EXTRN	CARTPAGE

GETFMAP:DEC	DE			;0 IS THE EMPTY MAP
	LD	A,E			;PAGE = 7BIT-E | D<<1
	RLCA
	LD	A,D
	RLCA
	PUSH	AF
	LD	A,E			;OFFSET = 0-6BIT-E * 128
	AND	7FH
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,CARTSEG
	ADD	HL,DE
	POP	AF
	ADD	A,LEVELPAGE+1
	LD	E,A
	CALL	CARTPAGE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = MAP NUMBER

	CSEG
	PUBLIC	GETTMAP

GETTMAP:CALL	GETFMAP			;TILE INFOMATION IS LOCATED AFTER
	LD	DE,MAPXSIZ*MAPYSIZ	;THE MAP INFORMATION
	ADD	HL,DE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = MAP NUMBER
;OUTPUT:A = CARTRIDGE PAGE
;	HL = OFFSET

	CSEG
	PUBLIC	GETHMAP
	EXTRN	CARTPAGE

GETHMAP:DEC	DE			;0 IS THE EMPTY MAP
	LD	A,E			;PAGE = 7-8BITS-E | D<<2
	RLCA
	RLCA
	AND	3
	LD	H,A
	LD	A,D
	RLCA
	RLCA
	OR	H

	PUSH	AF
	LD	A,E			;OFFSET = 0-5BIT-E * 64
	AND	3FH
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,CARTSEG
	ADD	HL,DE
	POP	AF
	ADD	A,HEIGHTPAGE
	LD	E,A
	CALL	CARTPAGE
	RET

