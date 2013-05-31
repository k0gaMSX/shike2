

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
;INPUT:	DE = XY COORDENATES
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
;INPUT:	BC = SCREEN COORDENATES
;OUTPUT:ZF = 1 WHEN NO VALID

	CSEG

ISVALID:BIT	7,D			;CHECK IF THE SCREEN POSITION IS
	JR	NZ,I.NOK		;NEGATIVE
	BIT	7,E
	JR	NZ,I.NOK
	LD	A,NR_SCRCOL-1		;OR THE X POSITION IS OUTSIDE
	CP	D
	JR	C,I.NOK
	LD	A,NR_SCRROW-1		;OR THE Y POSITION IS OUTSIDE
	CP	E
	JR	C,I.NOK
	OR	1
	RET

I.NOK:	XOR	A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = PATTERN
;	B = PATTERN NUMBER
;	C = Z VALUE
;	(M.HGHT) = HEIGHT LEVEL


	CSEG
	EXTRN	ADDZPAT,LMMM,VDPPAGE

MAPPAT:	CALL	ISVALID
	RET	Z
	LD	(MP.COOR),DE
	LD	A,B
	LD	(MP.NPAT),A
	LD	A,(M.HGHT)
	CALL	ADDZPAT			;ADD ZVALUE
	RET	Z

	LD	A,LOGTIMP
	LD	(LOGOP),A
	LD	A,PATPAGE
	LD	(VDPPAGE),A

	LD	DE,(MP.COOR)
	CALL	PAT2XY
	PUSH	HL
	LD	DE,(MP.NPAT)
	CALL	PNUM2XY
	POP	DE
	LD	BC,1008H
	JP	LMMM			;DRAW THE PATTERN

	DSEG
MP.COOR:DW	0
MP.NPAT:DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN POSITION
;	A = FLOOR NUMBER
;	(M.HGHT) = HEIGHT LEVEL

	CSEG

FLOORFUN:
	DEC	A
	RLCA
	RLCA
	LD	C,A
	LD	B,0
	LD	HL,FLOORDEF
	ADD	HL,BC			;HL = ADDRESS OF FLOOR

	LD	A,(M.HGHT)
	ADD	A,A
	ADD	A,A
	LD	(F.ZVAL),A		;ZVAL IS CONSTANT IN FLOORS

	LD	(F.COOR),DE
	LD	BC,(F.ZVAL)
	LD	B,(HL)
	INC	HL
	LD	(F.PTR),HL
	CALL	MAPPAT

	LD	HL,(F.PTR)
	LD	DE,(F.COOR)
	INC	D
	LD	BC,(F.ZVAL)
	LD	B,(HL)
	INC	HL
	LD	(F.PTR),HL
	CALL	MAPPAT

	LD	HL,(F.PTR)
	LD	DE,(F.COOR)
	INC	E
	LD	BC,(F.ZVAL)
	LD	B,(HL)
	INC	HL
	LD	(F.PTR),HL
	CALL	MAPPAT

	LD	HL,(F.PTR)
	LD	DE,(F.COOR)
	INC	D
	INC	E
	LD	BC,(F.ZVAL)
	LD	B,(HL)
	JP	MAPPAT

	DSEG
F.COOR:	DW	0
F.PTR:	DW	0
F.ZVAL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN POSITION
;	A = TILE NUMBER

	CSEG
	EXTRN	MULTDEA

TILEFUN:PUSH	DE
	DEC	A
	LD	DE,TILE.SIZ		;TAKE ADDRESS OF THE TILE
	CALL	MULTDEA
	LD	DE,TILEDEF
	ADD	HL,DE
	LD	(T.PTR),HL
	POP	DE

	LD	A,(M.HGHT)
	ADD	A,A
	ADD	A,A			;ZVAL IS NOT CONSTANT IN TILES

	LD	B,TILEXSIZ
T.LOOPX:PUSH	BC			;LOOP OVER X
	PUSH	DE
	PUSH	AF

	LD	B,TILEYSIZ
	LD	C,A
T.LOOPY:PUSH	BC			;LOOP OVER Y
	PUSH	DE

	LD	HL,(T.PTR)
	LD	B,(HL)
	INC	HL
	LD	(T.PTR),HL
	CALL	MAPPAT
	POP	DE
	DEC	E
	POP	BC
	INC	C			;INCREMENT Z VALUE
	DJNZ	T.LOOPY

	POP	AF
	POP	DE
	INC	D
	POP	BC
	DJNZ	T.LOOPX

	RET

	DSEG
T.PTR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(M.MNUM) = FLOOR MAP NUMBER
;	(M.OFFS) = SCREEN OFFSET
;	(M.HGHT) = HEIGHT

	CSEG
	EXTRN	CARTPAGE

MAPTILE:LD	BC,(M.OFFS)		;CALCULATE INITIAL POSITION
	INC	C
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	FLOORDEF,TILEDEF

FLOORDEF:
	DB	0,0,0,0
	DB	16,17,32,33
	DB	48,49,64,65
	DB	80,81,96,97
	DB	112,113,128,129
	DB	144,145,160,161
	DB	176,177,192,193


TILEDEF:
        ;STAIRS = 0
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DB	50,34,18,0,0,0,0,            51,35,19,0,0,0,0,               1
	DB	1,66,34,18,0,0,0,            0,51,35,19,0,0,0,               2
	DB	1,3,66,34,18,0,0,            0,0,51,35,19,0,0,               3
	DB	1,3,3,66,34,18,0,            0,0,0,51,35,19,0,               4

	DB	0,0,0,52,36,20,0,            2,4,4,67,37,21,0,               4
	DB	0,0,52,36,20,0,0,            2,4,67,37,21,0,0,               3
	DB	0,52,36,20,0,0,0,            2,67,37,21,0,0,0,               2
	DB	52,36,20,0,0,0,0,            53,37,21,0,0,0,0,               1


	;WALL1 = 8
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DB	0,0,0,0,5,18,0,              0,0,0,0,38,21,0,                4
	DB	1,3,3,3,5,18,0,              0,0,0,0,38,21,0,                4
	DB	1,3,3,3,5,0,0,               2,4,4,4,6,21,0,                 4
	DB	0,0,0,0,5,0,0,               2,4,4,4,6,21,0,                 4

	DB	1,3,3,3,5,18,0,              0,0,0,0,6,0,0,                  4
	DB	1,3,3,3,5,18,0,              2,4,4,4,6,0,0,                  4
	DB	0,0,0,0,38,18,0,             2,4,4,4,6,21,0,                 4
	DB	0,0,0,0,38,18,0,             0,0,0,0,6,21,0,                 4



	;WALL2 = 16
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DB	0,0,0,0,82,18,0,             0,0,0,0,38,21,0,                4
	DB	130,114,98,114,82,18,0,      0,0,0,0,38,21,0,                4
	DB	130,114,98,114,82,0,0,       131,115,99,115,83,21,0,         4
	DB	0,0,0,0,82,0,0,              131,115,99,115,83,21,0,         4

	DB	130,114,98,114,82,18,0,      0,0,0,0,83,0,0,                 4
	DB	130,114,98,114,82,18,0,      131,115,99,115,83,0,0,          4
	DB	0,0,0,0,38,18,0,             131,115,99,115,83,21,0,         4
	DB	0,0,0,0,38,18,0,             0,0,0,0,83,21,0,                4




	;COLUMNS = 24
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DB	210,194,178,178,162,146,0,  211,195,179,179,163,147,0,       4
	DB	210,194,178,178,178,84,0,   211,195,179,179,179,85,0,        4
	DB	68,178,178,178,178,84,0,    69,179,179,179,179,85,0,         4
	DB	68,178,178,178,162,146,0,   69,179,179,179,163,147,0,        4




