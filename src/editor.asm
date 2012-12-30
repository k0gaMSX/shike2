	INCLUDE SHIKE2.INC
	INCLUDE BIOS.INC

TILEPAG		EQU	0
TILESPR		EQU	0
TILEPAT		EQU	0
PATTERNSPR	EQU	1
PATTERNPAT	EQU	4
PATTERNPAG	EQU	1

NUMBERPAT	EQU	8
NUMBERSPR	EQU	3
NUMBERCOORD	EQU	06080H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
	PUBLIC	EDITOR
	EXTRN  	TILE,DELSPR,SETPAGE,SPRITE,COLORSPRITE,EXIT
EDITOR:
	LD	C,TILEPAT
	LD	DE,TILEGEN
	CALL	SPRITE		;TEMPORAL CALL
	LD	C,TILESPR
	LD	DE,TILECOL
	CALL	COLORSPRITE	;TEMPORAL CALL

	LD	C,PATTERNPAT
	LD	DE,PATTERNGEN
	CALL	SPRITE		;TEMPORARY CALL
	LD	C,PATTERNSPR
	LD	DE,PATTERNCOL
	CALL	COLORSPRITE	;TEMPORARY CALL

	LD	B,10
	LD	C,NUMBERPAT
	LD	DE,NUMBERGEN
.NUMLOOP:
	PUSH	BC
	PUSH	DE
	CALL	SPRITE
	POP	DE
	POP	BC
	LD	HL,32
	ADD	HL,DE
	EX	DE,HL
	LD	A,4
	ADD	A,C
	LD	C,A
	DJNZ	.NUMLOOP

	LD	HL,0
	LD	(TILE),HL
	LD	(PATTERN),HL

.ELOOP:	CALL	DELSPR			;MAIN EDITOR LOOP
	LD	A,TILEPAG
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE
	CALL	GRID			;SHOW ISOMETRIC GRID
	CALL	SELTILE			;SELECT THE TILE

	CALL	DELSPR
	LD	A,PATTERNPAG
	LD	(DPPAGE),A
	LD	(ACPAGE),A
	CALL	SETPAGE			;SHOW PATTERNS PAGE
	CALL	SELPATTERN		;SELECT THE PATTERN

	CALL	DELSPR
	LD	A,TILEPAG
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE
	CALL	SELREGION
	JR	.ELOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		D = X TILE POSITION
;		E = Y TILE POSITION

	CSEG

TILE2PAT:
	LD	A,E			;CONVERT FROM TILE SPACE
	ADD	A,A			;TO PATTERN NUMBER
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		(ACPAGE) = PAGE
	CSEG
	PUBLIC	GRID
	EXTRN	LINE,VDPSYNC

GRID:
	LD	A,GRIDCOLOR
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
	CALL	VDPSYNC			;IT IS THE END, WAIT TO THE VDP
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






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(PATTERN) = ACTUAL SELECTED PATTERN

	CSEG
	EXTRN	TILE2XY,GETCHAR,PUTSPRITE

SELPATTERN:
	EXTRN	HMMV

	XOR	A
	LD	(FORCLR),A
	LD	DE,NR_PATROW*8
	LD	BC,212-NR_PATROW*8
	CALL	HMMV

	LD	DE,(PATTERN)
.PATLOOP:
	LD	(PATTERN),DE		;SAVE THE POSITION OF THE PATTERN
	LD	C,PATTERNSPR
	LD	B,PATTERNPAT
	CALL	TILE2XY
	CALL	PUTSPRITE		;PAINT THE PATTERN MARQUEE
	LD	DE,(PATTERN)
	CALL	TILE2PAT
	CALL	PRINTNUM		;PRINT THE PATTERN NUMBER
	CALL	GETCHAR			;WAIT A KEY
	LD	DE,(PATTERN)

	CP	KB_SPACE		;ESPACE SELECT PATTERN
	RET	Z

.PUP:	CP	KB_UP
	JR	NZ,.PDOWN
	XOR	A
	CP	E
	JR	Z,.PATLOOP
	DEC	E
	JR	.PATLOOP

.PDOWN:	CP	KB_DOWN
	JR	NZ,.PLEFT
	LD	A,NR_PATROW-1
	CP	E
	JR	Z,.PATLOOP
	INC	E
	JR	.PATLOOP

.PLEFT:	CP	KB_LEFT
	JR	NZ,.PRGTH
	XOR	A
	CP	D
	JR	Z,.PATLOOP
	DEC	D
	JR	.PATLOOP

.PRGTH:	CP	KB_RIGTH
	JR	NZ,.PATLOOP
	LD	A,NR_PATCOL-1
	CP	D
	JR	Z,.PATLOOP
	INC	D
	JR	.PATLOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(ACPAGE) = PAGE WHERE WILL BE PAINTED
;		(TILE) = ACTUAL TILE

	CSEG
	EXTRN	MARKREGION,GETCHAR,VDPSYNC

SELREGION:
	LD	A,LOGXOR
	LD	(LOGOP),A
	LD	A,MARKCOLOR
	LD	(FORCLR),A
	LD	BC,0

IR.LOOP:
	LD	(IR.INCS),BC		;STORE INCREMENTS
	CALL	MARKREGION		;PAINT THE RECTANGULE REGION
	CALL	VDPSYNC			;WAIT UNTIL THE END OF PAINTING
	CALL	GETCHAR			;WAIT A KEY
	PUSH	AF
	LD	BC,(IR.INCS)
	CALL	MARKREGION		;DELETE PREVIOUS REGION
	LD	BC,(IR.INCS)

        POP	AF
	CP	KB_ESC
	RET	Z

IR.RGH:	CP	KB_RIGTH
	JR	NZ,IR.LFT
	INC	B
	JR	IR.LOOP

IR.LFT:	CP	KB_LEFT
	JR	NZ,IR.UP
	LD	A,B
	OR	A
	JR	Z,IR.LOOP		;WE CAN NOT GO MORE LEFT THAN ORIGIN
	DEC	B
	JR	IR.LOOP

IR.UP:	CP	KB_UP
	JR	NZ,IR.DWN
	LD	A,C
	OR	A
	JR	Z,IR.LOOP		;WE CAN NOT GO UPPER ORIGIN
	DEC	C
	JR	IR.LOOP

IR.DWN:	CP	KB_DOWN
	JR	NZ,IR.LOOP
	INC	C
	JR	IR.LOOP

	DSEG
IR.INCS:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = NUMBER TO PRINT

	CSEG

PRINTNUM:
	LD	HL,.NUMBERBUF
	CALL	BCD			;CONVERT TO BCD

	LD	DE,NUMBERCOORD
	LD	HL,.NUMBERBUF
	LD	B,3
	LD	C,NUMBERSPR

.PLOOP:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A,(HL)			;GET THE DIGIT AND MULTIPLY BY 4
	ADD	A,A
	ADD	A,A
	ADD	A,NUMBERPAT		;ADD THE INITIAL DIGIT PATTERN
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
	DJNZ	.PLOOP
	RET

	DSEG
.NUMBERBUF:	DS	3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = NUMBER
;		HL = OUTPUT BUFFER

	CSEG
	PUBLIC	BCD

BCD:	LD	DE,.POT10

.BNEXT:	EX	AF,AF'
	LD	A,(DE)
	OR	A
	RET	Z		;0 MARKS END OF POT10 ARRAY
	LD	B,A
	LD	C,0
        EX	AF,AF'

.BLOOP:	SUB	B
	JR	C,.BIGGER
	INC	C
	JR	.BLOOP

.BIGGER:			;THE POT10 ELEMENT IS BIGGER THAN OUR NUMBER
	ADD	A,B		;SO RESTORE VALUE AND PASS TO THE NEXT ELEMENT
	LD	(HL),C
	INC	DE
	INC	HL
	JR	.BNEXT

.POT10:	DB	100,10,1,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILE) = ACTUAL TILE SELECTED

	CSEG
	EXTRN	TILE,TILE2XY,GETCHAR,PUTSPRITE,EXIT

SELTILE:
	LD	DE,(TILE)

.TLOOP:	LD	(TILE),DE		;SAVE THE TILE SELECTION
	LD	C,TILESPR
	LD	B,TILEPAT
	CALL	TILE2XY
	CALL	PUTSPRITE		;PAINT THE TILE MARQUEE
	CALL	GETCHAR			;WAIT NEXT KEY
	LD	DE,(TILE)

	CP	KB_ESC
	CALL	Z,EXIT			;ESC = EXIT OF THE PROGRAM

	CP	KB_SPACE		;SPACE = SELECT THE TILE
	RET	Z

.TUP:	CP	KB_UP
	JR	NZ,.TDOWN
	XOR	A
	CP	E
	JR	Z,.TLOOP
	DEC	E
	JR	.TLOOP

.TDOWN:	CP	KB_DOWN
	JR	NZ,.TLEFT
	LD	A,NR_SCRROW-1
	CP	E
	JR	Z,.TLOOP
	INC	E
	JR	.TLOOP

.TLEFT:	CP	KB_LEFT
	JR	NZ,.TRGTH
	XOR	A
	CP	D
	JR	Z,.TLOOP
	DEC	D
	JR	.TLOOP

.TRGTH:	CP	KB_RIGTH
	JR	NZ,.TLOOP
	LD	A,NR_SCRCOL-1
	CP	D
	JR	Z,.TLOOP
	INC	D
	JR	.TLOOP


PATTERNGEN:
	DB	0FFH,080H,080H,080H,080H,080H,080H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0FFH,001H,001H,001H,001H,001H,001H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H

TILEGEN:
	DB	003H,00CH,030H,0C0H,0C0H,030H,00CH,003H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	0C0H,030H,00CH,003H,003H,00CH,030H,0C0H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

TILECOL:
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH

PATTERNCOL:
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH
	DB	0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH

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

	DSEG

PATTERN:	DW	0


