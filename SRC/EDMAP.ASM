
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC
	INCLUDE SPRITE.INC

POINTCOL	EQU	15

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.MAP
	EXTRN	SPRITE,SETCOLSPR,EDINIT,VDPSYNC,LISTEN

ED.MAP:	CALL	EDINIT
	LD	C,POINTPAT
	LD	DE,PATDATA
	LD	B,4
	CALL	SPRITE

	LD	C,POINTSPR
	LD	E,POINTCOL
	LD	B,1
	CALL	SETCOLSPR

	LD	HL,0
	LD	(COORD),HL
	LD	A,1
	LD	(RFSH),A

ED.LOOP:
	CALL	REFRESH
	LD	DE,RECEIVERS
	CALL	LISTEN
	JR	NZ,ED.LOOP
	RET

PATDATA:DB	010H,030H,070H,0FFH,0FFH,070H,030H,010H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

RECEIVERS:
	DB	1,29,166,8
	DW	ROOMEVENT
	DB	54,30,166,8
	DW	FLOOREVENT
	DB	130,30,166,8
	DW	GENHEIGHT
	DB	160,30,166,8
	DW	DOOREVENT
	DB	190,30,166,8
	DW	RFSH.ON
	DB	160,30,174,8
	DW	OBJEVENT
	DB	190,30,174,8
	DW	RFSH.OFF
	DB	1,29,174,8
	DW	HEIGHTEVENT
	DB	54,30,174,8
	DW	TILEEVENT
	DB	130,30,174,8
	DW	CHAREVENT
	DB	1,254,32,127
	DW	MAPEVENT
	DB	1,254,1,127
	DW	HELP
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	CLRVPAGE,PUTLPAGE,VDPSYNC

REFRESH:
	LD	A,(RFSH)
	OR	A
	RET	Z
	LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	PUTLPAGE
	CALL	GETMDATA
	CALL	SHOWSCR
	JP	VDPSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	EDLEVEL,EDROOM,MULTDEA,PTRHL,GETROOM

GETMDATA:				;UPDATE THE MAP VARIABLES
	LD	HL,0
	LD	(RPTR),HL
	LD	(MAPNO),HL

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	A,(HEIGHT)
	CALL	GETROOM
	RET	Z
	LD	(RPTR),HL
	CALL	PTRHL
	LD	(MAPNO),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CSEG
	EXTRN	PUTSPRITE,GLINES,LOCATE,PRINTF
	EXTRN	EDLEVEL,EDROOM,MAPMAP,ZVALINIT

SHOWSCR:LD	DE,21
	CALL	LOCATE

	LD	H,0
	LD	DE,(EDLEVEL)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	DE,(EDROOM)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	DE,(COORD)
	LD	L,E
	PUSH	HL
	LD	L,D
	PUSH	HL
	LD	A,(TILE)
	LD	L,A
	PUSH	HL
	LD	A,(HEIGHT)
	LD	L,A
	PUSH	HL
	LD	A,(FLOOR)
	LD	L,A
	PUSH	HL
	LD	DE,(MAPNO)
	PUSH	DE
	LD	DE,FMT
	CALL	PRINTF			;PRINT INFORMATION

	CALL	ZVALINIT
	XOR	A			;WE MAP ALWAYS AS HEIGHT 0
	LD	BC,MAP.CENTRAL
	LD	DE,(MAPNO)
	CALL	MAPMAP			;MAP THE FLOOR

	LD	DE,MAPG
	LD	C,15
	CALL	GLINES			;DRAW BUTTONS

	LD	D,120
	LD	A,(ACTION)
	RLCA
	RLCA
	RLCA
	ADD	A,168
	LD	E,A
	LD	B,POINTPAT
	LD	C,POINTSPR
	JP	PUTSPRITE		;SHOW THE SELECTED ACTION


FMT:	DB	" MAP",9," %04d FLOOR",9,"%03d",9
	DB	" UPDATE",9," DOORS",9," RFSH+",10
	DB	" HEIGHT",9,"   %02d TILE",9,"%03d",9
	DB	" CHARS",9, " OBJECT",9, " RFSH-",10
	DB	" POS=%03dX%03d,ROOM=%02dX%02d,LEVEL=%02dX%02d",0

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
MAPG:	DB     	9,  0,   95, 127, 32, 16,  8, 16,  8
	DB	9,  0,   96, 127,159, 16, -8, 16, -8
	DB	3,  0,  166,  30,166,  0,  8,  0,  8
	DB	2,  0,  166,   0,182, 30,  0, 30,  0
	DB	3,  54, 166,  84,166,  0,  8,  0,  8
	DB	2,  54, 166,  54,182, 30,  0, 30,  0
	DB	3, 130, 166, 220,166,  0,  8,  0,  8
	DB	4, 130, 166, 130,182, 30,  0, 30,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

RFSH.ON:
	LD	A,1
	LD	(RFSH),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

RFSH.OFF:
	XOR	A
	LD	(RFSH),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDINATES
;OUTPUT:HL = COORDENATES


ISOX	EQU	128
ISOY	EQU	32

	CSEG

SCR2WRL:LD	C,E
	LD	B,D

	LD	L,B
	LD	H,0			;HL = X
	LD	DE,ISOX
	OR	A
	SBC	HL,DE			;HL = X' = X - ISOX
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			;HL = 16X'
	PUSH	HL
	PUSH	HL

	LD	L,C
	LD	H,0			;HL = Y
	LD	DE,ISOY
	OR	A
	SBC	HL,DE			;HL = Y' = Y - ISOY
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL			;HL = 32Y'
	POP	DE			;DE = 16X'
	PUSH	HL

	OR	A
	SBC	HL,DE			;HL = 32Y' - 16X'
	LD	A,H

	POP	HL			;HL = Y'
	POP	DE			;DE = X'
	ADD	HL,DE			;HL = 32Y' + 16X'
	SRL	H			;H = (32Y' + 16X')/(32*16)
	LD	L,A
	SRL	L			;L = (32Y' - 16X')/(32*16)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

ROOMEVENT:
	CP	MS_BUTTON1		;LEFT BUTTON INCREMENT ROOM NUMBER
	LD	DE,(MAPNO)
	JR	NZ,R.1
	LD	HL,NR_MAPS
	CALL	DCOMPR
	RET	Z
	INC	DE
	JR	R.RET

R.1:	CP	MS_BUTTON2
	RET	NZ
	LD	A,E			;RIGTH BUTTON DECREMENT ROOM NUMBER
	OR	D
	RET	Z
	DEC	DE
R.RET:	LD	(MAPNO),DE		;UPDATE MAP NUMBER
	LD	HL,(RPTR)
	LD	(HL),E			;UPDATE THE ROOM MATRIX
	INC	HL
	LD	(HL),D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG

HEIGHTEVENT:
	CP	MS_BUTTON1
	JR	NZ,H.1
	LD	A,(HEIGHT)
	CP	NR_HEIGHTS-1
	RET	Z
	INC	A
	JR	H.RET

H.1:	CP	MS_BUTTON2
	RET	NZ
	LD	A,(HEIGHT)
	OR	A
	RET	Z
	DEC	A
H.RET:	LD	(HEIGHT),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG
	EXTRN	ED.FLOOR

FLOOREVENT:
	CP	MS_BUTTON2
	JR	Z,F.1
	CP	MS_BUTTON1
	RET	NZ

	LD	A,1
	LD	(RFSH),A
	CALL	ED.FLOOR
	JR	Z,F.1
	LD	(FLOOR),A

F.1:	XOR	A
	LD	(ACTION),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = SCREEN LOCATION

	CSEG
	EXTRN	ED.TSEL

TILEEVENT:
	CP	MS_BUTTON2
	JR	Z,T.1
	CP	MS_BUTTON1
	RET	NZ

	LD	A,1
	LD	(RFSH),A
	CALL	ED.TSEL
	JR	Z,T.1
	LD	(TILE),A

T.1:	LD	A,1
	LD	(ACTION),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG
	EXTRN	SHOWHLP

HELP:	CP	KB_F1
	RET	NZ

	LD	DE,HLPMSG
	CALL	SHOWHLP
	LD	A,1
	LD	(RFSH),A
	RET

HLPMSG:	DB	"SELECT   - SELECT CURRENT ROOM POSITION",0AH
	DB	"INS      - FILL ROOM WITH CURRENT FLOOR",0AH
	DB	"DEL      - CLEAR CURRENT FLOOR MAP",0AH
	DB	"[MAP]    - SELECT MAP NUMBER FOR CURRENT ROOM",0AH
	DB	"[HEIGHT] - SELECT HEIGHT FOR CURRENT ROOM",0AH
	DB	"[FLOOR]  - ENTER FLOOR MENU",0AH
	DB	"[TILE]   - ENTER TILE MENU",0AH
	DB	"[UPDATE] - UPDATE FLOOR HEIGHT FOR CURRENT ROOM",0AH
	DB	"[CHARS]  - ENTER CHARACTER MENU",0AH
	DB	"[DOORS]  - ENTER DOOR MENU",0AH
	DB	"[OBJECT] - ENTER OBJECT MENU",0AH
	DB	"[RFSH+]  - ENABLE SCREEN REFRESH",0AH
	DB	"[RFSH-]  - DISABLE SCREEN REFRESH",0AH
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT
;	DE = SCREEN COORDINATES

	CSEG
	EXTRN	GETFMAP,ADDAHL,GETTMAP,MEMSET

MAPEVENT:
	LD	(M.EV),A

	CP	KB_F1
	JP	Z,HELP

	LD	HL,(MAPNO)
	LD	A,L
	OR	H
	RET	Z			;MAP 0 MEANS NO MAP

	CALL	SCR2WRL			;TRANSFORM SCREEN COORDENATES
	LD	A,H			;TO MAP COORDENATES
	BIT	7,A
	RET	NZ
	CP	LVLXSIZ			;CHECK IF THE COORDENATES ARE IN
	RET	NC			;THE CORRECT RANGE
	LD	A,L
	BIT	7,A
	RET	NZ
	CP	LVLYSIZ
	RET	NC
	LD	(M.COOR),HL
	LD	A,L
	RLCA
	RLCA
	RLCA
	ADD	A,H
	LD	(M.OFFSET),A		;OFFSET IN THE MAP

	LD	A,(M.EV)
	CP	KB_SELECT
	JR	NZ,M.ACT

	LD	HL,(M.COOR)
	LD	(COORD),HL
	RET

M.ACT:	LD	A,(ACTION)
	OR	A
	JR	NZ,M.TILE

M.FLOOR:LD	DE,(MAPNO)		;GET THE ADDRESS OF THE MAP
	CALL	GETFMAP
	LD	A,(M.EV)
	CP	KB_INS
	JR	NZ,M.DEL

	LD	A,(FLOOR)
	JR	M.MEM

M.DEL:	CP	KB_DEL
	JR	NZ,M.FMS
	XOR	A

M.MEM:	LD	BC,MAPXSIZ*MAPYSIZ
	JP	MEMSET

M.FMS:	LD	A,(M.OFFSET)
	CALL	ADDAHL
	LD	A,(M.EV)
	CP	MS_BUTTON2		;BUTTON 2 RESETS THE FLOOR
	JR	NZ,N.FMS1
	XOR	A
	JR	M.FMS2

N.FMS1:	CP	MS_BUTTON1		;BUTTON 1 SETS THE FLOOR
	RET	NZ
	LD	A,(FLOOR)

M.FMS2:	LD	(HL),A
	RET

M.TILE:	LD	DE,(MAPNO)		;GET THE ADDRESS OF THE MAP
	CALL	GETTMAP
	LD	A,(M.OFFSET)
	CALL	ADDAHL

	LD	A,(M.EV)
	CP	MS_BUTTON2		;BUTTON 2 RESETS THE TILE
	JR	NZ,M.TMS1
	XOR	A
	JR	M.TMS2

M.TMS1:	CP	MS_BUTTON1		;BUTTON 1 SETS THE TILE
	RET	NZ
	LD	A,(TILE)

M.TMS2:	LD	(HL),A
	RET


	DSEG
M.EV:		DB	0
M.COOR:		DW	0
M.OFFSET:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT

	CSEG
	EXTRN	GETHMAP,MULTEA,GETTMAP,TILEDEF
	PUBLIC	GENHEIGHT

GENHEIGHT:
	CP	MS_BUTTON1
	RET	NZ

	LD	DE,(MAPNO)
	CALL	GETTMAP			;HL = TILE MAP
	LD	DE,G.TBUF
	LD	BC,ROOMXSIZ*ROOMYSIZ
	LDIR				;COPY TILE MAP
	LD	DE,(MAPNO)
	CALL	GETFMAP
	LD	DE,G.FBUF
	LD	BC,ROOMXSIZ*ROOMYSIZ
	LDIR				;COPY FLOOR MAP

	LD	DE,(MAPNO)
	CALL	GETHMAP
	EX	DE,HL			;DE = HEIGHT POINTER

	LD	HL,G.TBUF		;HL = TILE MAP
	LD	BC,G.FBUF		;BC = FLOOR MAP
	LD	(G.PTR),BC
	LD	B,ROOMXSIZ*ROOMYSIZ

G.LOOP:	PUSH	BC
	PUSH	HL
	PUSH	DE

	LD	A,(HL)			;TAKE TILE NUMBER
	OR	A
	JR	NZ,G.TILE
	LD	HL,(G.PTR)		;TAKE FLOOR NUMBER
	LD	A,(HL)
	OR	A
	LD	A,NOHEIGHT		;IF NO TILE AND NO FLOOR THEN
	JR	Z,G.NFLR		;   HEIGHT = NOHEIGHT
	XOR	A			;IF NO TILE THEN
	JR	G.NTILE			;   HEIGHT = HEIGHT LEVEL * 4

G.TILE:	DEC	A
	LD	E,TILE.SIZ
	CALL	MULTEA
	LD	DE,TILEDEF
	ADD	HL,DE
	LD	DE,TILE.HEIGHT
	ADD	HL,DE			;HL = TILE->HEIGHT
	LD	A,(HL)			;A = BASE HEIGHT

G.NTILE:LD	B,A
	LD	A,(HEIGHT)
	ADD	A,A
	ADD	A,A
	ADD	A,B			;A = HEIGHT

G.NFLR:	POP	DE
	LD	(DE),A			;WRITE HEIGHT
	INC	DE			;UPDATE POINTERS
	LD	HL,(G.PTR)
	INC	HL
	LD	(G.PTR),HL
	POP	HL
	INC	HL
	POP	BC
	DJNZ	G.LOOP
	RET


	DSEG
G.PTR:	DW	0
G.FBUF:	DS	ROOMXSIZ*ROOMYSIZ
G.TBUF:	DS	ROOMXSIZ*ROOMYSIZ

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ED.CHAR,EDLEVEL,EDROOM

CHAREVENT:
	CP	MS_BUTTON1
	RET	NZ

	LD	A,1
	LD	(RFSH),A
	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	HL,(COORD)
	LD	A,(HEIGHT)
	ADD	A,A
	ADD	A,A
	JP	ED.CHAR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ED.DOOR,EDLEVEL,EDROOM

DOOREVENT:
	CP	MS_BUTTON1
	RET	NZ

	LD	A,1
	LD	(RFSH),A
	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	HL,(COORD)
	LD	A,(HEIGHT)
	ADD	A,A
	ADD	A,A
	JP	ED.DOOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	ED.OBJECT,EDLEVEL,EDROOM

OBJEVENT:
	CP	MS_BUTTON1
	RET	NZ

	LD	A,1
	LD	(RFSH),A
	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	LD	HL,(COORD)
	LD	A,(HEIGHT)
	ADD	A,A
	ADD	A,A
	JP	ED.OBJECT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
ACTION:	DB	0
COORD:	DW	0
MAPNO:	DW	0
HEIGHT:	DB	0
RPTR:	DW	0
FLOOR:	DB	0
TILE:	DB	0
RFSH:	DB	0
