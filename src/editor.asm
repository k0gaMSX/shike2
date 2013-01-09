	INCLUDE SHIKE2.INC
	INCLUDE BIOS.INC

POINTERSPR	EQU	0
NUMBERSPR	EQU	4
TILEPAT		EQU	0
PATTERNPAT	EQU	4
NUMBERPAT	EQU	8
NUMBERCOORD	EQU	06080H


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
	PUBLIC	EDITOR
	EXTRN	PATTERN,TILE,SPRITE,COLORSPRITE,EXIT
EDITOR:
	LD	C,TILEPAT
	LD	DE,TILEGEN
	CALL	SPRITE		;TEMPORAL CALL

	LD	C,PATTERNPAT
	LD	DE,PATTERNGEN
	CALL	SPRITE		;TEMPORARY CALL

	LD	C,POINTERSPR
	LD	DE,POINTERCOL
	CALL	COLORSPRITE	;TEMPORARY CALL

	LD	B,10
	LD	C,NUMBERPAT
	LD	DE,NUMBERGEN
.NUMLOOP:			;TEMPORARY LOOP
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
	LD	(E.TILE),HL
	XOR	A
	LD	(PATTERN),A

	LD	A,TILPAGE
	LD	(ACPAGE),A
	CALL	GRID			;SHOW ISOMETRIC GRID

	LD	HL,0
	ADD	HL,SP
	LD	(EDSTACK),HL		;SAVE SP FOR CANCEL OPERATIONS

	;MAIN EDITOR LOOP
EDLOOP: CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	SELTILE			;SELECT THE TILE
	CALL	SELPATTERN		;SELECT THE PATTERN
	LD	A,(ISOTILE)
	OR	A
	CALL	Z,SELREGION		;SELECT THE REGION, ONLY IN REGION MODE
;	CALL	ISOCMD			;EXECUTE CMD
	JR	EDLOOP

	DSEG
E.TILE:		DW	0
EDSTACK:	DW	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GETKEV

EDKEV:
	CALL	GETKEV
	CP	KB_F5
	CALL	Z,EXIT
	CP	KB_ESC
	RET	NZ
	LD	HL,(EDSTACK)		;LONGJMP TO EDITOR LOOP. CANCEL
	LD	SP,HL			;ANY OPERATION
	JP	EDLOOP


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
	EXTRN	PAT2TILE,METAPAT,MARKMETAPAT

SELMETAPAT:
	CALL	DELSPR
	LD	DE,(PATTERN-1)		;TRANSFORM PATTERN NUMBER TO
	CALL	PAT2TILE
	LD	(M.TILE),DE
	LD	BC,0101H

M.LOOP:	LD	(METAPAT),BC
	CALL	MARKMETAPAT		;MARK THE META PATTERN
	CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	EDKEV			;GET NEXT KEYBOARD EVENT
	PUSH	AF
	CALL	MARKMETAPAT		;ERASE META PATTERN MARK
	POP	AF
	LD	BC,(METAPAT)
	LD	DE,(M.TILE)

	CP	KB_SPACE
	RET	Z

M.UP:	CP	KB_UP
	JR	NZ,M.DOWN
	LD	A,1
	CP	C
	JR	Z,M.LOOP
	DEC	C
	JR	Z,M.LOOP

M.DOWN:	CP	KB_DOWN
	JR	NZ,M.LOOP
	LD	A,E
	ADD	A,C
	CP	16			;256 PATTERNS OF 16X8 GIVES 16 ROWS
	JR	Z,M.LOOP
	INC	C
	JR	M.LOOP

	DSEG
M.TILE:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(PATTERN) = ACTUAL SELECTED PATTERN

	CSEG
	EXTRN	DELSPR,SETPAGE,PATTERN,TILE2XY,PAT2XY,PUTSPRITE

SELPATTERN:
	CALL	DELSPR
	LD	A,PATPAGE
	LD	(DPPAGE),A
	LD	(ACPAGE),A
	CALL	SETPAGE			;SHOW PATTERNS PAGE
	LD	DE,(PATTERN-1)

P.LOOP:	LD	A,D
	LD	(PATTERN),A		;SAVE THE POSITION OF THE PATTERN
	LD	BC,PATTERNPAT*256 + POINTERSPR
	CALL	PAT2XY
	CALL	PUTSPRITE		;PAINT THE PATTERN MARQUEE
	LD	A,(PATTERN)
	CALL	PRINTNUM		;PRINT THE PATTERN NUMBER
	CALL	EDKEV			;WAIT A KEYBOARD EVENT
	LD	DE,(PATTERN-1)

P.SPC:	CP	KB_SPACE		;SPACE SELECT PATTERN
	JR	NZ,P.UP
	JP	SELMETAPAT

P.UP:	CP	KB_UP			;WE DON'T CHECK LIMITS BECAUSE
	JR	NZ,P.DOWN		;ALL THE 256 POSITIONS ARE CORRECT
	LD	A,D
	SUB	16
	LD	D,A
	JR	P.LOOP

P.DOWN:	CP	KB_DOWN
	JR	NZ,P.LEFT
	LD	A,D
	ADD	A,16
	LD	D,A
	JR	P.LOOP

P.LEFT:	CP	KB_LEFT
	JR	NZ,P.RGTH
	XOR	A
	CP	D
	JR	Z,P.LOOP
	DEC	D
	JR	P.LOOP

P.RGTH:	CP	KB_RIGTH
	JR	NZ,P.LOOP
	LD	A,D
	CP	255
	JR	Z,P.LOOP
	INC	D
	JR	P.LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(ACPAGE) = PAGE WHERE WILL BE PAINTED
;		(TILE) = ACTUAL TILE

	CSEG
	EXTRN	SETPAGE,DELSPR,TILEINC,MARKREGION,VDPSYNC

SELREGION:
	CALL	DELSPR
	LD	A,TILPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE
	XOR	A
	LD	(IR.MODE),A		;SET DEFAULT MODE
	LD	DE,(TILE)
	LD	BC,0101H

IR.LOOP:
	LD	(TILEINC),BC		;STORE INCREMENTS
	LD	(TILE),DE		;STORE ACTUAL TILE
	CALL	MARKREGION		;PAINT THE RECTANGULE REGION
	CALL	VDPSYNC			;WAIT UNTIL THE END OF PAINTING
	CALL	EDKEV			;WAIT A KEYBOARD EVENT
	PUSH	AF
	CALL	MARKREGION		;DELETE PREVIOUS REGION
	LD	BC,(TILEINC)
	LD	DE,(TILE)

	POP	AF
IR.SPC:	CP	KB_SPACE		;SELECT THE REGION WITH SPACE
	RET	Z

	LD	L,A
	AND	7Fh
	CP	KB_SHIFT		;SHIFT CHANGE THE MODE (PRESS/RELEASE)
	JR	NZ,IR.BODY
	LD	A,(IR.MODE)
	CPL
	LD	(IR.MODE),A
	JR	IR.LOOP
		
IR.BODY:LD	A,(IR.MODE)
	OR	A
	LD	A,L
	JR	Z,IR.NORMAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CP	KB_RIGTH		;IN THE SPECIAL MODE YOU CAN MOVE THE
	JR	NZ,SP.LFT		;SELECTION, INSTEAD OF CHANGING THE
	INC	D			;SIZE LIKE YOU DO IN NORMAL MODE
	DEC	E			;SO, IN THIS MODE IT IS MODIFIED (TILE)
	JR	IR.LOOP

SP.LFT:	CP	KB_LEFT
	JR	NZ,SP.UP
	DEC	D
	INC	E
	JR	IR.LOOP

SP.UP:	CP	KB_UP
	JR	NZ,SP.DWN
	DEC	D
	DEC	E
	JR	IR.LOOP

SP.DWN:	CP	KB_DOWN
	JR	NZ,IR.LOOP
	INC	D
	INC	E
	JR	IR.LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IR.NORMAL:
	CP	KB_RIGTH		;IN NORMAL MODE YOU CHANGE THE SIZE OF
	JR	NZ,NR.LFT		;THE SELECTION, SO IT IS MODIFIED
	INC	B			;(TILEINC)
	JR	IR.LOOP

NR.LFT:	CP	KB_LEFT
	JR	NZ,NR.UP
	LD	A,1
	CP	B
	JR	Z,IR.LOOP		;WE CAN NOT GO MORE LEFT THAN ORIGIN
	DEC	B
	JR	IR.LOOP

NR.UP:	CP	KB_UP
	JR	NZ,NR.DWN
	LD	A,1
	CP	C
	JP	Z,IR.LOOP		;WE CAN NOT GO UPPER ORIGIN
	DEC	C
	JP	IR.LOOP

NR.DWN:	CP	KB_DOWN
	JP	NZ,IR.LOOP
	INC	C
	JP	IR.LOOP

	DSEG
IR.MODE:	DB	0

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
;INPUT:		DE = ACTUAL TILE SELECTED

	CSEG
	EXTRN	PUTSPRITE,TILE2XY,ISOTILE

MARKTILE:
	LD	B,TILEPAT
	LD	A,(ISOTILE)
	OR	A
	JR	Z,MT.1
	LD	B,PATTERNPAT

MT.1:	LD	C,POINTERSPR
	CALL	TILE2XY
	JP	PUTSPRITE		;PAINT THE TILE MARQUEE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		(TILE) = ACTUAL TILE SELECTED

	CSEG
	EXTRN	DELSPR,SETPAGE,TILE,ISOTILE,TILE2XY,PUTSPRITE,EXIT

SELTILE:
	LD	DE,(E.TILE)		;RESTORE SAVED TILE
	LD	(TILE),DE
	CALL	DELSPR
	LD	A,TILPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SHOW WORKING PAGE
	LD	DE,(TILE)

T.LOOP:	LD	(TILE),DE		;SAVE THE TILE SELECTION
	CALL	MARKTILE		;PAINT THE TILE MARQUEE
	CALL	EDKEV			;WAIT NEXT KEYBOARD EVENT
	LD	DE,(TILE)

	CP	KB_SELECT
	JR	NZ,T.SPACE
	LD	A,(ISOTILE)
	XOR	1
	LD	(ISOTILE),A
	JR	T.LOOP

T.SPACE:CP	KB_SPACE		;SPACE = SELECT THE TILE
	JR	NZ,T.SHFT
	LD	DE,(TILE)		;SAVE TILE SELECTED BY THE USER
	LD	(E.TILE),DE
	RET

T.SHFT:	LD	L,A
	AND	7Fh
	CP	KB_SHIFT		;SHIFT CHANGE THE MODE (PRESS/RELEASE)
	JR	NZ,T.BODY
	LD	A,(T.MODE)
	CPL
	LD	(T.MODE),A
	JR	T.LOOP

T.BODY:	LD	A,(T.MODE)
	OR	A
	LD	A,L
	JR	Z,T.UP

TI.UP:	CP	KB_UP			;THIS CODE PERFROMS ISOMETRIC MOVEMENT
	JR	NZ,TI.DOWN
	XOR	A
	CP	E
	JR	Z,T.LOOP
	DEC	E
	DEC	D
	JR	T.LOOP

TI.DOWN:CP	KB_DOWN
	JR	NZ,TI.LEFT
	LD	A,NR_SCRROW-1
	CP	E
	JR	Z,T.LOOP
	INC	E
	INC	D
	JR	T.LOOP

TI.LEFT:CP	KB_LEFT
	JR	NZ,TI.RGTH
	XOR	A
	CP	D
	JR	Z,T.LOOP
	LD	A,E
	CP	NR_SCRROW-1
	JR	Z,T.LOOP
	DEC	D
	INC	E
	JR	T.LOOP

TI.RGTH:CP	KB_RIGTH
	JR	NZ,T.LOOP
	LD	A,NR_SCRCOL-1
	CP	D
	JR	Z,T.LOOP
	XOR	A
	CP	E
	JP	Z,T.LOOP
	INC	D
	DEC	E
	JP	T.LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T.UP:	CP	KB_UP			;THIS CODE PERFORMS EUCLIDEAN MOVEMENT
	JR	NZ,T.DOWN
	XOR	A
	CP	E
	JP	Z,T.LOOP
	DEC	E
	JP	T.LOOP

T.DOWN:	CP	KB_DOWN
	JR	NZ,T.LEFT
	LD	A,NR_SCRROW-1
	CP	E
	JP	Z,T.LOOP
	INC	E
	JP	T.LOOP

T.LEFT:	CP	KB_LEFT
	JR	NZ,T.RGTH
	XOR	A
	CP	D
	JP	Z,T.LOOP
	DEC	D
	JP	T.LOOP

T.RGTH:	CP	KB_RIGTH
	JP	NZ,T.LOOP
	LD	A,NR_SCRCOL-1
	CP	D
	JP	Z,T.LOOP
	INC	D
	JP	T.LOOP

	DSEG
T.MODE:	DB	0

	CSEG

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

POINTERCOL:
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



