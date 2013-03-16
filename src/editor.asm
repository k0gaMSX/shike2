	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC
	INCLUDE	GEOMETRY.INC
	INCLUDE	KBD.INC


TOPSPR		EQU	0
BOTSPR		EQU	1
ZSPR		EQU	2
NUMSPR		EQU	28

ERRORCOORD	EQU	0808H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDLAYERS,GAMELAYERS

EDLAYERS:
	LD	A,1			;ENABLE ALL LAYERS
	JR	L.AUX

GAMELAYERS:
	XOR	A			;ENABLE ONLY MAP LAYER
L.AUX:	LD	(ENAGRID),A
	LD	(ENALIMITS),A
	LD	(ENAHEIGTHS),A
	LD	A,1
	LD	(ENAMAP),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDINIT
	EXTRN	SETCOLSPR,DELSPR,SPRITE

EDINIT:	CALL	CLRSPR
	CALL	EDLAYERS

	LD	BC,28*256 + TOPSPR
	LD	E,MARKCOLOR
	CALL	SETCOLSPR

	LD	BC,4*256 + NUMSPR
	LD	E,NUMCOLOR
	CALL	SETCOLSPR

	LD	BC,13*256 + TILEPAT	;TOP + BOT + TILE + 10 NUMBERS
	LD	DE,TILEGEN
	JP	SPRITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.KEVENT,ED.KPRESS,FUNKEYS
	EXTRN	PTRCALL,KEVENT,KPRESS

ED.KPRESS:
	CALL	KPRESS
	JR	K.AUX

ED.KEVENT:
	CALL	KEVENT

K.AUX:	CALL	FUNKEYS
	PUSH	AF
	CALL	NZ,ED.SCREEN
	POP	AF
	RET

;;;;;;;;;;;;;;;;;;

FUNKEYS:LD	(K.KEY),A
	CP	KB_F1
	JR	NZ,K.F2
	LD	A,(ENAGRID)
	XOR	1
	LD	(ENAGRID),A
	JR	K.RET

K.F2:	CP	KB_F2
	JR	NZ,K.F3
	LD	A,(ENAMAP)
	XOR	1
	LD	(ENAMAP),A
	JR	K.RET

K.F3:	CP	KB_F3
	JR	NZ,K.F4
	LD	A,(ENALIMITS)
	XOR	1
	LD	(ENALIMITS),A
	JR	K.RET

K.F4:	CP	KB_F4
	JR	NZ,K.NOFUN
	LD	A,(ENAHEIGTHS)
	XOR	1
	LD	(ENAHEIGTHS),A
	JR	K.RET

K.NOFUN:CP	A			;SET Z = 1
	RET

K.RET:	LD	A,(K.KEY)
	OR	A			;SET Z = 0
	RET

	DSEG
K.KEY:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	TILESPRITE
	EXTRN	PUTSPRITE

TILESPRITE:
	LD	(MT.COORD),DE
	LD	A,C
	LD	(MT.ZVAL),A
	CALL	DELSPR

	LD	DE,(MT.COORD)
	LD	A,(MT.ZVAL)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	NEG
	ADD	A,E
	LD	E,A
	LD	BC,TILEPAT*256 + TOPSPR
	CALL	PUTSPRITE			;PAINT THE TILE MARK

	LD	A,(MT.ZVAL)
	OR	A
	RET	Z

	LD	DE,(MT.COORD)			;WE HAVE HEIGTH, SO WE HAVE
	LD	A,E				;TO PAINT THE BOTTON PART
	SUB	8
	LD	E,A
	LD	(MT.COORD),DE
	LD	BC,BOTPAT*256 + BOTSPR
	CALL	PUTSPRITE

	LD	A,(MT.ZVAL)
	DEC	A
	RET	Z
	LD	B,A				;AND LIKE THE HEIGTH > 1
	LD	C,ZSPR				;WE HAVE TO PAINT THE MIDDLE
	LD	DE,(MT.COORD)			;PART

MT.LOOP:PUSH	BC
	PUSH	DE
	LD	B,ZPAT
	LD	A,E
	SUB	4
	LD	E,A
	CALL	PUTSPRITE
	POP	DE
	LD	A,E
	SUB	8
	LD	E,A
	POP	BC
	INC	C
	DJNZ	MT.LOOP
	RET

	DSEG
MT.COORD:	DW	0
MT.ZVAL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		(ACPAGE) = PAGE

	CSEG
	EXTRN	LINE

SHOWLIMITS:
	LD	A,LIMITCOLOR
	LD	IY,L.DATA
	JR	S.AUX	

SHOWGRID:
	LD	A,GRIDCOLOR
	LD	IY,G.DATA

S.AUX:	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A

G.NEXT:	LD	A,(IY+0)
	OR	A
	RET	Z
	LD	D,(IY+1)		;LOAD NEXT LINE
	LD	E,(IY+2)
	LD	B,(IY+3)
	LD	C,(IY+4)

G.LINE:	PUSH	AF
	PUSH	IY			;PAINT THE LINE
	PUSH	BC
	PUSH	DE
	CALL	LINE
	POP	DE
	POP	BC
	POP	IY

	LD	A,D			;USE THE INCREMENTS OF THE TABLE
	ADD	A,(IY+5)		;AND GET NEXT LINE
	LD	D,A
	LD	A,E
	ADD	A,(IY+6)
	LD	E,A
	LD	A,B
	ADD	A,(IY+7)
	LD	B,A
	LD	A,C
	ADD	A,(IY+8)
	LD	C,A
	POP	AF
	DEC	A
	JR	NZ,G.LINE

	LD	DE,9			;PASS TO NEXT ELEMENT OF THE TABLE
	ADD	IY,DE
	JR	G.NEXT

;	       REP  X0  Y0    X1  Y1 IX0 IY0 IX1 IY1
G.DATA:	DB	16,248,  0,  255,  3,-16,  0,  0,  8
	DB	10,  0,  4,  255,131,  0,  8,  0,  8
	DB	16,  0, 84,  247,207,  0,  8,-16,  0
	DB	16,248,207,  255,204,-16,  0,  0, -8
	DB	10,  0,203,  255, 76,  0, -8,  0, -8
	DB	16,  0,123,  247,  0,  0, -8,-16,  0
	DB	0

L.DATA:	DB	1, 215,  0,    0,107,  0,  0,  0,  0
	DB	1,   0,108,  199,207,  0,  0,  0,  0
	DB	1,  56,207,  255,108,  0,  0,  0,  0
	DB	1, 255,107,   40,  0,  0,  0,  0,  0
	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POINTER TO BUFFER BEGINNING

	CSEG
	EXTRN	H.DECRUNCH

SHOWHEIGTHS:
	EX	DE,HL
	LD	A,L
	OR	H
	RET	Z			;NO HEIGTH BUFFER YET
	LD	A,(HL)
	OR	A
	RET	Z

	INC	HL
	LD	B,A
S.LOOP:	PUSH	BC
	CALL	H.DECRUNCH
	PUSH	HL
	CALL	DRAWSQUARE
	POP	HL
	POP	BC
	DJNZ	S.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LEFT-UP CORNER OF THE SQUARE
;	BC = SIZE OF THE SQUARE

	CSEG
	EXTRN	LINE,WRLD2SCR

DRAWSQUARE:
	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	A,SQRCOLOR
	LD	(FORCLR),A

	EX	DE,HL
	LD	(D.LU),HL		;LEFT-UP CORNER
	LD	A,L
	ADD	A,C
	LD	L,A
	LD	(D.LD),HL		;LEFT-DOWN CORNER
	LD	A,H
	ADD	A,B
	LD	H,A
	LD	(D.RD),HL		;RIGTH-DOWN CORNER
	LD	A,L
	SUB	C
	LD	L,A
	LD	(D.RU),HL		;RIGTH-UP CORNER
	LD	DE,CENTRAL.P1X
	LD	BC,CENTRAL.P1Y
	XOR	A
	CALL	WRLD2SCR
	DEC	L			;ADJUST THE POSITION BECAUSE WRLD2SCR
	LD	D,L			;RETURNS THE CENTRAL POSITION
	LD	A,E
	SUB	4
	LD	E,A
	LD	(D.RU),DE		;RIGTH-UP CORNER IN SCR COORDENATES

	LD	HL,(D.RD)
	LD	DE,CENTRAL.P1X
	LD	BC,CENTRAL.P1Y
	XOR	A
	CALL	WRLD2SCR
	DEC	L			;ADJUST THE POSITION BECAUSE WRLD2SCR
	LD	D,L
	LD	A,E
	SUB	4
	LD	E,A
	LD	(D.RD),DE		;RIGTH-DOWN CORNER IN SCR COORDENATES

	LD	HL,(D.LU)
	LD	DE,CENTRAL.P1X
	LD	BC,CENTRAL.P1Y
	XOR	A
	CALL	WRLD2SCR
	LD	D,L			;ADJUST THE POSITION BECAUSE WRLD2SCR
	LD	A,E			;RETURNS THE CENTRAL POSITION
	SUB	4
	LD	E,A
	LD	(D.LU),DE		;LEFT-UP CORNER IN SCR COORDENATES

	LD	HL,(D.LD)
	LD	DE,CENTRAL.P1X
	LD	BC,CENTRAL.P1Y
	XOR	A
	CALL	WRLD2SCR
	LD	D,L			;ADJUST THE POSITION BECAUSE WRLD2SCR
	LD	A,E			;RETURNS THE CENTRAL POSITION
	SUB	4
	LD	E,A
	LD	(D.LD),DE		;LEFT-DOWN CORNER IN SCR COORDENATES

	LD	BC,(D.RD)
	CALL	LINE			;LINE LEFT-DOWN TO RIGTH-DOWN
	LD	DE,(D.RD)
	LD	BC,(D.RU)
	CALL	LINE			;LINE RIGTH-DOWN TO RIGTH-UP
	LD	DE,(D.RU)
	LD	BC,(D.LU)
	CALL	LINE			;LINE RIGTH-UP TO LEFT-UP
	LD	DE,(D.LU)
	LD	BC,(D.LD)
	JP	LINE			;LINE LEFT-UP TO LEFT-DOWN

	DSEG
D.LU:	DW	0
D.LD:	DW	0
D.RU:	DW	0
D.RD:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: E = NUMBER TO DISPLAY
;	BC = COORDENATES WHERE DISPLAY THE NUMBER

	CSEG
	PUBLIC	NUM2SPR
	EXTRN	PUTSPRITE,ITOA

NUM2SPR:PUSH	BC
	LD	A,E
	LD	DE,N.BUF
	CALL	ITOA			;CONVERT TO STRING

	POP	DE
	LD	HL,N.BUF
	LD	B,3
	LD	C,NUMSPR

N.LOOP:	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A,(HL)			;GET THE DIGIT AND MULTIPLY BY 4
	SUB	'0'
	ADD	A,A
	ADD	A,A
	ADD	A,NUMPAT		;ADD THE INITIAL DIGIT PATTERN
	LD	B,A
	CALL	PUTSPRITE
	POP	BC
	POP	DE
	POP	HL
	INC	HL			;PASS TO NEXT DIGIT
	INC	C			;PASS TO NEXT SPRITE
	LD	A,8			;INCREMENT X COORDENATE
	ADD	A,D
	LD	D,A
	DJNZ	N.LOOP
	RET

	DSEG
N.BUF:	DS	4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	PERROR
	EXTRN	DELSPR,MAPERR,CLRVPAGE,LOCATE,ARYDE,PUTS,KPRESS,VDPSYNC

PERROR:	CALL	DELSPR
	LD	E,TILPAGE		;CLEAR THE SCREEN
	CALL	CLRVPAGE
	LD	DE,ERRORCOORD
	CALL	LOCATE			;LOCATE THE CURSOR IN THE BEGINNING
	LD	DE,E.TBL
	LD	A,(MAPERR)
	DEC	A
	CALL	ARYDE			;TAKE THE POINTER TO THE STRING
	CALL	PUTS			;PRINT IT
	CALL	VDPSYNC
	CALL	KPRESS			;WAIT A KEY
	RET

E.TBL:	DW	E.MSG1,E.MSG2,E.MSG3
E.MSG1:	DB	"TOO MUCH PATTERNS IN THIS TILE POSITION",0
E.MSG2:	DB	"NEW PATTERN HAS SMALLER Z THAN PREVIOUS",0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.SCREEN
	EXTRN	CLRVPAGE,DISSCR,DISSPR,ENASCR,ENASPR,VDPSYNC
	EXTRN	CMDBUF,HGTBUF

ED.SCREEN:
	CALL	DISSCR
	CALL	DISSPR
	LD	E,0
	CALL	CLRVPAGE		;CLEAN THE PAGE 0

	LD	A,TILPAGE
	LD	(ACPAGE),A

	LD	DE,(CMDBUF)
	LD	BC,(HGTBUF)
	CALL	DBGSCR

	CALL	VDPSYNC
	CALL	ENASPR
	JP	ENASCR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = MAP BUFFER
;	BC = HEIGTH BUFFER

	CSEG
	PUBLIC	DBGSCR
	EXTRN	MAP

DBGSCR:	PUSH	BC
	PUSH	DE

	LD	A,(ENAGRID)
	OR	A
	CALL	NZ,SHOWGRID		;SHOW ISOMETRIC GRID

	POP	DE
	LD	A,(ENAMAP)
	OR	A
	CALL	NZ,MAP			;SHOW MAP

	LD	A,(ENALIMITS)
	OR	A
	CALL	NZ,SHOWLIMITS		;SHOW SCREEN LIMITS

	POP	DE
	LD	A,(ENAHEIGTHS)
	OR	A
	CALL	NZ,SHOWHEIGTHS		;SHOW HEIGTH SQUARES
	RET

	DSEG
ENAGRID:	DB	0
ENAMAP:		DB	0
ENALIMITS:	DB	0
ENAHEIGTHS:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

TILEGEN:DB	003H,00CH,030H,0C0H,0C0H,030H,00CH,003H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0C0H,030H,00CH,003H,003H,00CH,030H,0C0H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


BOTGEN:	DB	000H,000H,000H,000H,080H,080H,080H,080H
	DB	080H,080H,080H,080H,0C0H,030H,00CH,003H
	DB	000H,000H,000H,000H,001H,001H,001H,001H
	DB	081H,081H,081H,081H,083H,08CH,0B0H,0C0H

ZGEN:	DB	080H,080H,080H,080H,080H,080H,080H,080H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	001H,001H,001H,001H,081H,081H,081H,081H
	DB	080H,080H,080H,080H,000H,000H,000H,000H

NUMBERGEN:
	DB	07CH,077H,063H,063H,063H,077H,03EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	00CH,01CH,01CH,00CH,00CH,01FH,03EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	03CH,07EH,04EH,01CH,038H,073H,07EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	03FH,066H,04CH,01EH,007H,067H,03EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	030H,064H,06CH,03FH,00CH,00CH,008H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	07EH,033H,030H,03EH,007H,067H,03EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	01EH,030H,06EH,07BH,061H,073H,03EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	03FH,073H,007H,00EH,01CH,018H,018H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	03EH,077H,063H,03EH,063H,077H,03EH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

	DB	03EH,067H,043H,06FH,03BH,006H,03CH,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H



