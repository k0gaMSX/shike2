
	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC
	INCLUDE	EDITOR.INC
	INCLUDE	KBD.INC
	INCLUDE	GEOMETRY.INC

PTRSPR		EQU	0
MAPSPR		EQU	1
RIGTHSPR	EQU	2
DOWNSPR		EQU	3
UPSPR		EQU	4
LEFTSPR		EQU	5

MAPPAT		EQU	LASTPAT
PTRRPAT		EQU	MAPPAT+4		;THESE PATTERNS ARE DEFINED
PTRDPAT		EQU	PTRRPAT+4		;IN THE SAME ORDER THAN
PTRUPAT		EQU	PTRDPAT+4		;DIRECTIONS IN GEOMETRY.INC
PTRLPAT		EQU	PTRUPAT+4


LISTCOORD	EQU	00003H			;LETTER COORDENATES
MAPCOORD	EQU	03050H			;SCREEN COORDENATE
TEXTCOORD	EQU	03010H			;LETTER COORDENATES
ERRORCOORD	EQU	00000H			;LETTER COORDENATES
ARROWCOORD	EQU	0C450H			;SCREEN COORDENATES


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDLEVEL
	EXTRN	VDPSYNC,EDINIT

EDLEVEL:CALL	EDINIT
	LD	HL,0
	ADD	HL,SP
	LD	(EDSTACK),HL

ED.LOOP:CALL	LEVELSCR
	CALL	VDPSYNC
	CALL	SELLEVEL
	CALL	SELROOM
	JR	ED.LOOP

	DSEG

EDSTACK:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

EXIT:	LD	HL,(EDSTACK)		;LONGJMP FOR EXITING OF EDITOR.
	LD	SP,HL
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ROOM POSITION
;OUTPUT:HL = SCREEN COORDINATES

	CSEG

ROOM2XY:LD	A,D
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ERROR STRING

	CSEG
	EXTRN	PUTCHAR,VDPSYNC,LOCATE,PRINTF,KPRESS

ERROR:	LD	DE,ERRORCOORD
	CALL	LOCATE
	LD	DE,NEW.ERR
	CALL	PRINTF			;PRINT THE ERROR CODE
	CALL	VDPSYNC			;WAIT TO THE VDP
	CALL	KPRESS			;WAIT KEY PRESS

	LD	DE,ERRORCOORD
	CALL	LOCATE
	LD	B,64

E.LOOP:	PUSH	BC			;CLEAN THE ERROR LINE
	LD	A,' '
	CALL	PUTCHAR
	POP	BC
	DJNZ	E.LOOP
	CALL	VDPSYNC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POSITION OF THE ROOM

	CSEG
	EXTRN	ROOMADDR

SETROOM:PUSH	AF
	CALL	ROOMADDR
	POP	AF
	LD	(HL),A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POSITION OF ROOM

	CSEG
	EXTRN	ROOM2MAP,ROOM2HGT,GETROOM,EDMAPPER,EDHEIGTH,VDPSYNC
	EXTRN	NEWMAP,NEWHEIGTH

EDITROOM:
	CP	KB_F1
	JR	Z,E.BEGIN
	CP	KB_F2
	RET	NZ

E.BEGIN:LD	(E.KEY),A
	LD	(E.ROOM),DE
	CALL	GETROOM			;RETURN IF ROOM = -1
	RET	Z

	LD	DE,(E.ROOM)
	CALL	ROOM2MAP		;TAKE THE MAP ADDRESS
	EX	DE,HL
	CALL	NEWMAP
	LD	DE,(E.ROOM)
	CALL	ROOM2HGT		;TAKE THE HEIGTH ADDRESS
	EX	DE,HL
	CALL	NEWHEIGTH

	LD	A,(E.KEY)
	CP	KB_F1
	CALL	Z,EDMAPPER
	LD	A,(E.KEY)
	CP	KB_F2
	CALL	Z,EDHEIGTH

	CALL	LEVELSCR		;REPAINT LEVEL EDITOR SCREEN
	CALL	DRAWLEVEL		;DRAW THE LEVEL
	LD	DE,(E.ROOM)
	CALL	ROOMINFO		;REPAINT ROOM INFO
	CALL	VDPSYNC			;WAIT TO THE VDP
	RET	

	DSEG
E.ROOM:	DW	0
E.KEY:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT: A = NUMBER OF NEW ROOM, OR -1 WHEN NO MORE FREE ROOMS

	CSEG
	PUBLIC	NEWROOM

NEWROOM:XOR	A
	LD	B,NR_ROOMS

N.LOOP:	PUSH	BC
	LD	BC,LVLROOMSIZ
	LD	HL,LVLROOM
	CPIR
	JR	NZ,N.FOUND
	INC	A
	POP	BC
	DJNZ	N.LOOP
	LD	DE,NEW.ERR
	CALL	ERROR
	LD	A,-1
	JR	N.RET

N.FOUND:POP	BC
N.RET:	CP	-1
	RET

NEW.ERR:"NO MORE FREE ROOMS",0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ROOM LOCATION

	CSEG
	EXTRN	ACCADDR,KEY2DIR

SELACC:	LD	(A.ROOM),DE
	CALL	ACCADDR
	LD	(A.PTR),HL
A.LOOP:	CALL	KEVENT
	CP	128+KB_CRTL
	RET	Z			;CONTROL RELEASED, RETURNS

	CALL	KEY2DIR			;IS IT A DIRECTION?
	JR	C,A.LOOP
	LD	B,1			;OK TOGGLE THE BIT
	OR	A
	JR	Z,A.ELOOP
A.SHIFT:SLA	B
	DEC	A
	JR	NZ,A.SHIFT

A.ELOOP:LD	HL,(A.PTR)
	LD	A,(HL)
	XOR	B
	LD	(HL),A
	LD	DE,(A.ROOM)
	CALL	ROOMINFO		;UPDATE ROOM INFORMATION
	JR	A.LOOP

	DSEG
A.PTR:	DW	0
A.ROOM:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	GETROOM,KEVENT,PUTSPRITE,KEY2DIR,MOVEUC,PRINTF,VDPSYNC

SELROOM:LD	DE,0
	JR	R.PRINT			;PRINT MAP NUMBER OF 0,0

R.LOOP:	LD	DE,(R.ROOM)
	CALL	ROOM2XY
	EX	DE,HL
	LD	C,MAPSPR
	LD	B,MAPPAT
	CALL	PUTSPRITE		;MARK THE MAP
	CALL	KEVENT
	LD	(R.KEY),A
	LD	DE,(R.ROOM)

	CP	KB_CRTL			;CONTROL BEGIN ACCESS MODE
	JR	NZ,R.ESC
	CALL	SELACC
	JR	R.LOOP

R.ESC:	CP	KB_ESC			;ESC ENDS WITH THE LEVEL EDITION
	RET	Z

R.DEL:	CP	KB_DEL			;DELETE REMOVES THE ROOM
	JR	NZ,R.INS
	LD	A,-1
	JR	R.MOD			;WRITE -1 IN THIS ROOM

R.INS:	CP	KB_INS			;INSERT ADDS NEW ROOM
	JR	NZ,R.KDIR
	CALL	GETROOM			;CHECK IF THE ROOM IS ALREADY DEFINED
	JR	NZ,R.LOOP
	LD	DE,(R.ROOM)
	CALL	NEWROOM			;GET FREE ROOM NUMBER
	JR	Z,R.LOOP		;(NO MORE FREE ROOMS)
R.MOD:	LD	DE,(R.ROOM)
	PUSH	DE
	PUSH	DE
	CALL	SETROOM			;ASSIGN THE ROOM NUMBER
	POP	DE
	CALL	DRAWROOM		;COLORIZE THE ROOM
	POP	DE
	JR	R.PRINT			;UPDATE THE SCREEN


R.KDIR:	CALL	KEY2DIR
	JR	NC,R.DIR
	LD	A,(R.KEY)		;RESTORE KEY
	CALL	EDITROOM
	JR	R.LOOP

R.DIR:	LD	DE,(R.ROOM)
	CALL	MOVEUC

	LD	A,-1			;CHECK LIMITS
	CP	D
	JR	Z,R.LOOP
	CP	E
	JR	Z,R.LOOP
	LD	A,(LVLXSIZ)
	CP	D
	JR	Z,R.LOOP
	LD	A,(LVLYSIZ)
	CP	E
	JR	Z,R.LOOP

R.PRINT:LD	(R.ROOM),DE
	CALL	ROOMINFO
	JP	R.LOOP

	DSEG
R.ROOM:	DW	0
R.KEY:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = ROOM LOCATION

	CSEG
	EXTRN	GETACC,HIDESPRITE

LARROWCOORD	EQU	ARROWCOORD-0600H
RARROWCOORD	EQU	ARROWCOORD+0800H
UARROWCOORD	EQU	ARROWCOORD-0006H
DARROWCOORD	EQU	ARROWCOORD+0008H

ROOMINFO:
	PUSH	DE			;PUSH THE ROOM LOCATION
	CALL	GETROOM
	LD	E,A
	PUSH	DE			;PUSH THE ROOM NUMBER
	LD	DE,TEXTCOORD
	CALL	LOCATE
	LD	DE,I.FMT		;PRINT THE ROOM NUMBER
	CALL	PRINTF

	POP	DE			;POP THE ROOM LOCATION
	CALL	GETACC
	LD	(I.ACC),A

	LD	IY,I.DATA
	LD	B,4

I.LOOP:	PUSH	BC
	LD	C,(IY+0)		;C = SPRITE NUMBER
	LD	B,(IY+1)		;B = PATTERN
	LD	L,(IY+2)		;L = MASK
	LD	E,(IY+3)
	LD	D,(IY+4)		;DE = COORD
	PUSH	IY
	LD	A,(I.ACC)
	AND	L
	JR	NZ,I.PUT
	CALL	HIDESPRITE		;REMOVE IT IF IS NOT ENABLED
	JR	I.ELOOP
I.PUT:	CALL	PUTSPRITE		;PUT IT IF IT IS ENABLED
I.ELOOP:POP	IY
	LD	DE,5
	ADD	IY,DE			;NEXT ARROW
	POP	BC
	DJNZ	I.LOOP

	CALL	VDPSYNC
	RET

I.DATA:	DB	RIGTHSPR,PTRRPAT,M.RIGTH
	DW	RARROWCOORD
	DB	LEFTSPR,PTRLPAT,M.LEFT
	DW	LARROWCOORD
	DB	UPSPR,PTRUPAT,M.UP
	DW	UARROWCOORD
	DB	DOWNSPR,PTRDPAT,M.DOWN
	DW	DARROWCOORD

I.FMT:	DB	"ROOM: %0d",0

	DSEG
I.ACC:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	DELSPR,PUTLEVEL,PUTSPRITE,KPRESS,MOVEUC,KEY2DIR

SELLEVEL:
	LD	A,(E.LEVEL)
	CALL	PUTLEVEL
	LD	A,(E.LEVEL)
	LD	DE,LISTCOORD
	ADD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,4*15			;2*TAB-1
	LD	BC,PTRRPAT*256 + PTRSPR
	CALL	PUTSPRITE
	CALL	KPRESS

	CP	KB_ESC			;ESC EXITS FROM EDITOR
	CALL	Z,EXIT

L.SPACE:CP	KB_SPACE		;SPACE SELECTS THE LEVEL
	JR	NZ,L.DIR
	CALL	DRAWLEVEL		;DRAW THE LEVEL
	CALL	VDPSYNC			;WAIT TO THE VDP
	RET

L.DIR:	CALL	KEY2DIR
	JR	C,SELLEVEL
	LD	DE,(E.LEVEL)
	CALL	MOVEUC

	LD	A,E			;CHECK LIMITS
	CP	-1
	JR	Z,SELLEVEL
	CP	NR_LEVELS
	JR	Z,SELLEVEL
	LD	(E.LEVEL),A
	JP	SELLEVEL

	DSEG

E.LEVEL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	PUTLEVEL,LINE

DRAWLEVEL:
	LD	A,(E.LEVEL)
	CALL	PUTLEVEL
	LD	A,LOGIMP
	LD	(LOGOP),A

	LD	A,LVLCOLOR
	LD	(FORCLR),A
	LD	DE,MAPCOORD
	LD	A,(LVLYSIZ)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,E
	LD	C,A
	LD	B,D
	LD	HL,0800H
	LD	A,(LVLXSIZ)
	INC	A
	CALL	GLINES			;DRAW VERTICAL LINES
	
	LD	DE,MAPCOORD
	LD	A,(LVLXSIZ)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,D
	LD	B,A
	LD	C,E
	LD	HL,0008H
	LD	A,(LVLYSIZ)
	INC	A
	CALL	GLINES			;DRAW HORIZONTAL LINES

	LD	A,LOGIMP
	LD	(LOGOP),A
	LD	A,(LVLXSIZ)
	LD	B,A
	LD	A,(LVLYSIZ)
	LD	C,A
	LD	DE,0

D.Y:	PUSH	BC			;LOOP OVER Y
	PUSH	DE

D.X:	PUSH	BC			;LOOP OVER X
	PUSH	DE
	CALL	DRAWROOM
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
;INPUT:	DE = ROOM LOCATION

	CSEG
	EXTRN	GETROOM,LMMV

DRAWROOM:
	PUSH	DE
	CALL	GETROOM			;TAKE THE COLOR OF THIS ROOM
	JR	Z,D.NOMAP
	LD	A,MAPCOLOR
	JR	D.SET
D.NOMAP:LD	A,MAPNOCOLOR
D.SET:	LD	(FORCLR),A
	POP	DE

	CALL	ROOM2XY
	EX	DE,HL
	INC	D
	INC	E
	LD	BC,0707H
	JP	LMMV			;PAINT THE RECTANGLE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SPRITE,SETCOLSPR,DELSPR
	

INITSPRITES:
	CALL	DELSPR
	LD	BC,5*256 + LASTPAT
	LD	DE,ED.SPRITES
	JP	SPRITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	PUTLEVEL,LOCATE,PRINTF
	EXTRN	DISSPR,ENASPR,DISSCR,ENASCR,CLRVPAGE

LEVELSCR:
	CALL	DELSPR
	CALL	INITSPRITES		;INITIALIZE THE SPRITES
	LD	A,LEVPAGE
	LD	(ACPAGE),A
	LD	(DPPAGE),A
	LD	E,LEVPAGE
	CALL	CLRVPAGE		;CLEAN THE PAGE

	LD	DE,LISTCOORD
	CALL	LOCATE
	XOR	A
	LD	(S.CONT),A

L.LOOP:	CALL	PUTLEVEL		;PRINT ALL THE LEVEL NAMES
	LD	A,(LVLYSIZ)
	LD	L,A
	PUSH	HL
	LD	A,(LVLXSIZ)
	LD	L,A
	PUSH	HL
	LD	HL,LVLNAME
	PUSH	HL
	LD	DE,L.FMT
	CALL	PRINTF
	LD	HL,S.CONT
	LD	A,(HL)
	INC	A
	LD	(HL),A
	CP	NR_LEVELS
	JR	NZ,L.LOOP
	RET

L.FMT:	9,9,"%s (%dX%d)",10,0

	DSEG
S.CONT:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

ED.SPRITES:
MAPGEN:	DB	0FFH,080H,080H,080H,080H,080H,080H,0FFH
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	080H,080H,080H,080H,080H,080H,080H,080H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

PTRRGEN:DB	080H,0C0H,0F0H,0F0H,0C0H,080H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

PTRDGEN:DB	0FCH,078H,030H,030H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

PTRUGEN:DB	030H,030H,078H,0FCH,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

PTRLGEN:DB	010H,030H,0F0H,0F0H,030H,010H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


