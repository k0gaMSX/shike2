	INCLUDE	BIOS.INC
	INCLUDE	VDP.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EDITOR.INC

TILEMARKCOL	EQU	12
NUMBERCOL	EQU	14
GRIDCOLOR1	EQU	6
GRIDCOLOR2	EQU	8

TOPSPR		EQU	0
BOTSPR		EQU	1
ZSPR		EQU	2
NUMSPR		EQU	29

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDINIT
	EXTRN	SETCOLSPR,DELSPR,SPRITE

EDINIT:	CALL	CLRSPR
	LD	BC,29*256 + TOPSPR
	LD	E,TILEMARKCOL
	CALL	SETCOLSPR

	LD	BC,3*256 + NUMSPR
	LD	E,NUMBERCOL
	CALL	SETCOLSPR

	LD	BC,13*256 + TILEPAT	;TOP + BOT + TILE + 10 NUMBERS
	LD	DE,TILEGEN
	JP	SPRITE

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

LIMITS:	LD	A,GRIDCOLOR2
	LD	(FORCLR),A
	LD	B,4
	LD	HL,L.DATA

L.LOOP:	PUSH	BC			;PAINT THE SCREEN LIMITS
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
	DJNZ	L.LOOP
	RET

;		X0  Y0   - X1  Y1
L.DATA:	DB	127, 44,    0,107
	DB	0  ,108,  127,171
	DB	128,171,  255,108
	DB	255,107,  128, 44

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		(ACPAGE) = PAGE

	CSEG
	EXTRN	LINE

GRID:	LD	A,GRIDCOLOR1
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
G.DTOP:


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	ED.SCREEN
	EXTRN	SHOWHEIGTHS,CLRVPAGE,DISSCR,DISSPR,MAP_,ENASCR,ENASPR,VDPSYNC

ED.SCREEN:
	CALL	DISSCR
	CALL	DISSPR
	LD	E,0
	CALL	CLRVPAGE		;CLEAN THE THREE PAGES

	LD	A,TILPAGE
	LD	(ACPAGE),A

	CALL	GRID			;SHOW ISOMETRIC GRID
	LD	DE,MAPBUF
	CALL	MAP_			;SHOW MAP
	CALL	LIMITS			;SHOW SCREEN LIMITS
	CALL	SHOWHEIGTHS		;SHOW HEIGTH SQUARES

	CALL	VDPSYNC
	CALL	ENASPR
	JP	ENASCR


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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
	PUBLIC	MAPBUF,HGTHBUF,HGTHMATRIX

MAPBUF:		DS	MAPSIZ
HGTHBUF:	DS	HEIGTHSIZ
HGTHMATRIX:	DS	HEIGTHMATRIXSIZ


