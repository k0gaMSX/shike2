
	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC
	INCLUDE	EDITOR.INC
	INCLUDE	KBD.INC
	INCLUDE	VDP.INC

PTRSPR		EQU	0
MAPSPR		EQU	1

PTRPAT		EQU	LASTPAT
MAPPAT		EQU	PTRPAT+4

NR_LEVELS	EQU	3
NR_MAPS		EQU	8
LISTCOORD	EQU	00003H
MAPCOORD	EQU	03080H
TEXTCOORD	EQU	03010H


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDLEVEL
	EXTRN	VDPSYNC,EDINIT,INITLEVELS

EDLEVEL:CALL	EDINIT
	CALL	INITLEVELS
	CALL	INITSPRITES
	CALL	LEVELSCR
	CALL	VDPSYNC

	CALL	SELLEVEL
	CALL	SELMAP
	CALL	GETCHAR
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = LEVEL NUMBER
;OUTPUT:IX = POINTER TO LEVEL

	CSEG
	EXTRN	MULTEA

GETLEVEL:
	LD	E,LEVEL.SIZ
	CALL	MULTEA
	EX	DE,HL			;DE = (LEVEL) * LEVEL.SIZ
	LD	IX,LEVELS
	ADD	IX,DE			;IX = LEVELS + LVLOFFSET
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = MAP POSITION
;OUTPUT:HL = SCREEN COORDINATES

	CSEG

MAP2XY:	LD	A,D
	RLCA
	RLCA
	RLCA
	LD	D,A
	LD	A,E
	RLCA
	RLCA
	RLCA
	LD	E,A
	LD	HL,MAPCOORD
	ADD	HL,DE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	PUTSPRITE,KEY2DIR,MOVEUC,PRINTF,VDPSYNC

SELMAP:	LD	A,(LEVEL)
	CALL	GETLEVEL		;IX POINT TO LEVEL ADDRESS
	LD	DE,0
        LD	(MAP),DE
	JR	M.PRINT			;PRINT MAP NUMBER OF 0,0

M.LOOP:	LD	DE,(MAP)
	CALL	MAP2XY
	EX	DE,HL
	LD	C,MAPSPR
	LD	B,MAPPAT
	CALL	PUTSPRITE		;MARK THE MAP
	CALL	GETCHAR

	CP	KB_SPACE		;SPACE SELECTS THE MAPS
	RET	Z

	CALL	KEY2DIR
	JR	C,M.LOOP
	LD	DE,(MAP)
	CALL	MOVEUC

	LD	A,-1			;CHECK LIMITS
	CP	D
	JR	Z,M.LOOP
	CP	E
	JR	Z,M.LOOP
	LD	A,D
	CP	(IX+LEVEL.XSIZ)
	JR	Z,M.LOOP
	LD	A,E
	CP	(IX+LEVEL.YSIZ)
	JR	Z,M.LOOP
	LD	(MAP),DE

M.PRINT:CALL	GETMAP
	LD	E,A
	PUSH	DE			;PUSH THE MAP NUMBER
	LD	DE,TEXTCOORD
	CALL	LOCATE
	LD	DE,M.FMT		;PRINT THE MAP NUMBER
	CALL	PRINTF
	CALL	VDPSYNC
	JR	M.LOOP

M.FMT:	DB	"MAP: %d",0

	DSEG
MAP:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	PUTSPRITE,GETCHAR,MOVEUC,KEY2DIR

SELLEVEL:
	LD	A,(LEVEL)
	LD	DE,LISTCOORD
	ADD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,4*15			;2*TAB-1
	LD	BC,PTRPAT*256 + PTRSPR
	CALL	PUTSPRITE
	CALL	GETCHAR

	CP	KB_SPACE		;SPACE SELECTS THE LEVEL
	JR	NZ,L.DIR
	CALL	DRAWLEVEL
	CALL	VDPSYNC
	RET

L.DIR:	CALL	KEY2DIR
	JR	C,SELLEVEL
	LD	DE,(LEVEL)
	CALL	MOVEUC

	LD	A,E			;CHECK LIMITS
	CP	-1
	JR	Z,SELLEVEL
	CP	NR_LEVELS
	JR	Z,SELLEVEL
	LD	(LEVEL),A
	JR	SELLEVEL

	DSEG

LEVEL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	(LEVEL) = ACTUAL LEVEL SELECTED

	CSEG
	EXTRN	LEVELS,MULTEA,LINE

DRAWLEVEL:
	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	A,(LEVEL)
	CALL	GETLEVEL		;IX = POINT TO LEVEL ADDRESS

	LD	A,LVLCOLOR
	LD	(FORCLR),A
	LD	DE,MAPCOORD
	LD	A,(IX+LEVEL.YSIZ)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,E
	LD	C,A
	LD	B,D
	LD	HL,0800H
	LD	A,(IX+LEVEL.XSIZ)
	INC	A
	CALL	GLINES			;DRAW VERTICAL LINES
	
	LD	DE,MAPCOORD
	LD	A,(IX+LEVEL.XSIZ)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,D
	LD	B,A
	LD	C,E
	LD	HL,0008H
	LD	A,(IX+LEVEL.YSIZ)
	INC	A
	CALL	GLINES			;DRAW HORIZONTAL LINES
	CALL	DRAWMAPS
	RET


GLINES:	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	LINE
	POP	HL

	POP	DE			;INCREMENT ORIGIN POINT
	LD	A,D
	ADD	A,H
	LD	D,A
	LD	A,E
	ADD	A,L
	LD	E,A

	POP	BC			;INCREMENT DESTINE POINT
	LD	A,B
	ADD	A,H
	LD	B,A
	LD	A,C
	ADD	A,L
	LD	C,A

	POP	AF
	DEC	A
	JR	NZ,GLINES
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE LEVEL

	CSEG
	EXTRN	GETMAP,LMMV

DRAWMAPS:
	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	B,(IX+LEVEL.XSIZ)
	LD	C,(IX+LEVEL.YSIZ)
	LD	DE,0

D.Y:	PUSH	BC			;LOOP OVER Y
	PUSH	DE

D.X:	PUSH	BC			;LOOP OVER X
	PUSH	DE

	PUSH	DE
	CALL	GETMAP			;TAKE THE COLOR OF THIS MAP
	JR	Z,D.NOMAP
	LD	A,MAPCOLOR
	JR	D.SET
D.NOMAP:LD	A,MAPNOCOLOR
D.SET:	LD	(FORCLR),A
	POP	DE

	CALL	MAP2XY
	EX	DE,HL
	INC	D
	INC	E
	LD	BC,0707H
	CALL	LMMV			;PAINT THE RECTANGLE

	POP	DE			;NEXT X ITERATION
	INC	D
	POP	BC
	DJNZ	D.X

	POP	DE			;NEXT Y ITERATION
	INC	E
	POP	BC
	DEC	C
	JR	NZ,D.Y
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SPRITE,SETCOLSPR,DELSPR
	

INITSPRITES:
	CALL	DELSPR
	LD	BC,2*256 + PTRPAT
	LD	DE,ED.SPRITES
	JP	SPRITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	LEVELS,LOCATE,PRINTF
	EXTRN	DISSPR,ENASPR,DISSCR,ENASCR,CLRVPAGE,SETPAGE

LEVELSCR:
	CALL	DISSPR
	CALL	DISSCR
	LD	A,LEVPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	CALL	SETPAGE			;SET THE CORRECT PAGE
	LD	E,LEVPAGE
	CALL	CLRVPAGE		;CLEAN THE PAGE

	LD	DE,LISTCOORD
	CALL	LOCATE
	LD	B,NR_LEVELS
	LD	IX,LEVELS

L.LOOP:	PUSH	BC			;PRINT ALL THE LEVEL NAMES
	LD	L,(IX+LEVEL.YSIZ)
	PUSH	HL
	LD	L,(IX+LEVEL.XSIZ)
	PUSH	HL
	LD	L,(IX+LEVEL.NAME)
	LD	H,(IX+LEVEL.NAME+1)
	PUSH	HL
	LD	DE,L.FMT
	CALL	PRINTF
	LD	DE,LEVEL.SIZ
	ADD	IX,DE
	POP	BC
	DJNZ	L.LOOP

	CALL	ENASCR
	CALL	ENASPR
	RET

L.FMT:	9,9,"%s (%dX%d)",10,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ED.SPRITES:
PTRGEN:	DB	080H,0C0H,0F0H,0F0H,0C0H,080H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

MAPGEN:	DB	0FFH,081H,081H,081H,081H,081H,081H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H



