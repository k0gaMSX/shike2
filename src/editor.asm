
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDINIT
	EXTRN	CARTPAGE,LDLEVEL,DELSPR,MOUSE,MSCLR,CLRVPAGE

EDINIT:	CALL	DELSPR			;CLEAN SPRITES IN SCREEN
	LD	E,EDPAGE
	CALL	CLRVPAGE
	LD	A,1
	CALL	MOUSE
	CALL	MSCLR
	LD	DE,(EDLEVEL)
	PUSH	DE
	CALL	LDLEVEL

	LD	E,LEVELPAGE
	CALL	CARTPAGE
	POP	DE			;INITIALIZE THE EDITOR VARIABLES
	CALL	GETLEVEL		;FROM THE LEVEL DATA
	RET	Z

	PUSH	HL
	POP	IY
	LD	A,(IY+LVL.PAL)
	LD	(EDPAL),A
	LD	A,(IY+LVL.GFX)
	LD	(EDSET),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN POSITION

	CSEG
	PUBLIC	GRIDPOS

GRIDPOS:LD	A,E
	SUB	10H
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	LD	E,A

	LD	A,D
	SUB	10H
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	LD	D,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = DESTINE BUFFER
;	BC = CALLBACK FUNCTION

	CSEG
	PUBLIC	ADDGLISTEN

ADDGLISTEN:
	LD	(A.FUN),BC
	EX	DE,HL
	LD	DE,1010H
	LD	B,LVLYSIZ

A.LOOPY:PUSH	BC
	PUSH	DE
	LD	B,LVLXSIZ

A.LOOPX:PUSH	DE
	LD	(HL),D
	INC	HL
	LD	(HL),16
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),16
	INC	HL
	LD	DE,(A.FUN)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	POP	DE
	LD	A,D
	ADD	A,16
	LD	D,A
	DJNZ	A.LOOPX

	POP	DE
	LD	A,E
	ADD	A,16
	LD	E,A
	POP	BC
	DJNZ	A.LOOPY
	RET

	DSEG
A.FUN:	DW	0




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = ROOM LOCATION

	CSEG
	PUBLIC	COLORGRID16
	EXTRN	LMMV

COLORGRID16:
	LD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,16
	INC	A
	LD	D,A
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,16
	INC	A
	LD	E,A

	LD	BC,0F0FH
	LD	A,14
	LD	(FORCLR),A
	JP	LMMV

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GRID16
	EXTRN	LINE

GRID16:	LD	B,LVLYSIZ
	LD	DE,1010H

S.LOOPY:PUSH	BC
	PUSH	DE
	LD	B,LVLXSIZ

S.LOOPX:PUSH	BC
	PUSH	DE
	CALL	MARK
	POP	DE
	LD	A,D
	ADD	A,16
	LD	D,A
	POP	BC
	DJNZ	S.LOOPX

	POP	DE
	LD	A,E
	ADD	A,16
	LD	E,A
	POP	BC
	DJNZ	S.LOOPY
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = SCREEN COORDENATES OF THE MARK

	CSEG
	PUBLIC	MARK
	EXTRN	LINE

MARK:	LD	A,15
	LD	(FORCLR),A
	LD	A,LOGIMP
	LD	(LOGOP),A

	PUSH	DE
	PUSH	DE
	PUSH	DE
	LD	C,E
	LD	A,D
	ADD	A,16
	LD	B,A
	CALL	LINE			;UPPER LINE

	POP	DE
	LD	A,E
	ADD	A,16
	LD	E,A
	LD	C,A
	LD	A,D
	ADD	A,16
	LD	B,A
	CALL	LINE			;LOWER LINE

	POP	DE
	LD	B,D
	LD	A,E
	ADD	A,16
	LD	C,A
	CALL	LINE			;LEFT LINE

	POP	DE
	LD	A,D
	ADD	A,16
	LD	D,A
	LD	B,A
	LD	A,E
	ADD	A,16
	LD	C,A
	JP	LINE			;RIGHT LINE



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = DEFINITION OF GROUP OF LINES
;	C = COLOR

	CSEG
	PUBLIC	GLINES
	EXTRN	LINE

GLINES:	LD	IYL,E
	LD	IYU,D
	LD	A,C
	LD	(FORCLR),A
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = POINTER TO FIRST STACK
;	E = NUMBER OF STACKS
;	BC = SCREEN COORDENATES

	CSEG
	PUBLIC	DRAWSTACKS
	EXTRN	PSTACK

DRAWSTACKS:
	PUSH	DE
	PUSH	HL
	PUSH	BC
	EX	DE,HL
	CALL	PSTACK			;PRINT PATTERN STACK
	POP	BC
	LD	A,8			;INCREMENT Y COORDENATE
	ADD	A,C
	LD	C,A

	POP	HL
	LD	DE,NR_LAYERS		;PASS TO NEXT STACK
	ADD	HL,DE

	POP	DE
	DEC	E
	JR	NZ,DRAWSTACKS
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = POINTER TO THE PATTERN STACK
;OUTPUT:A = NUMBER OF USED LAYERS IN THE PATTERN STACK

	CSEG
	PUBLIC	GETNUMPAT

GETNUMPAT:
	XOR	A
	LD	BC,NR_LAYERS+1
	CPIR
	LD	A,NR_LAYERS
	SUB	C
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = XY COORDENATES
;OUTPUT:A = PATTERN NUMBER

	CSEG

XY2PAT:	LD	A,E
	AND	078H
	RLCA
	PUSH	AF

	LD	A,D
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	POP	HL
	OR	H
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	EXTRN	SETPAGE,PSELECT,SETPAGE

SELPAT:	LD	A,PATPAGE
	LD	(DPPAGE),A

	CALL	SETPAGE			;SET PATTERN PAGE
	CALL	PSELECT			;WAIT A PRESS EVENT
	CP	MS_BUTTON1		;MOUSE 1 SELECTS THE PATTERN
	JR	Z,S.1
	CP	KB_ESC			;ESC OR MOUSE2 RETURN
	JR	NZ,S.0
	CP	MS_BUTTON2
	JR	NZ,SELPAT

S.0:	XOR	A
	JR	S.END

S.1:	BIT	7,H			;USER CLICK IN A REGION OUT OF THE
	JR	NZ,SELPAT		;PATTERN AREA
	EX	DE,HL
	CALL	XY2PAT			;CALCULATE THE PATTERN NUMBER

S.END:	PUSH	AF
	LD	A,EDPAGE
	LD	(DPPAGE),A
	CALL	SETPAGE			;RESTORE THE EDITOR PAGE
	POP	AF			;RETURN THE PATTERN NUMBER OR ZERO
	OR	A			;IF USER CANCELS OPERATION
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = LAYER
;	BC = COORDENATE OFFSET
;	HL = PATTERN STACK


	CSEG

DELLAYER:
	DEC	E
	LD	D,0
	;CONTINUE IN ADDLAYER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = LAYER
;	D = PATTERN
;	BC = COORDENATE OFFSET
;	HL = PATTERN STACK

	CSEG

ADDLAYER:
	LD	A,D
	LD	D,0
	ADD	HL,BC			;POINTERT TO PATTERN
	ADD	HL,DE
	LD	(HL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = EVENT
;	DE = COORDENATE OFFSET
;	C = NUMBERS OF TILES
;	HL = POINTER TO PATTERN STACK

	CSEG
	PUBLIC	PATEVENT

PATEVENT:
	EX	AF,AF'
	LD	A,C
	LD	(P.NUM),A
	LD	(P.OFFSET),DE
	LD	(P.PTR),HL
	EX	AF,AF'

	CP	MS_BUTTON1		;MOUSE 1 ADDS A PATTERN
	JR	NZ,P1.1

	LD	A,(P.NUM)
	CP	NR_LAYERS
	CALL	NZ,SELPAT
	LD	DE,(P.NUM)
	LD	D,A
	LD	BC,(P.OFFSET)
	LD	HL,(P.PTR)
	CALL	NZ,ADDLAYER
	RET

P1.1:	CP	MS_BUTTON2
	RET	NZ

	LD	A,(P.NUM)
	OR	A			;MOUSE 2 DELETES A PATTERN
	LD	E,A
	LD	BC,(P.OFFSET)
	LD	HL,(P.PTR)
	CALL	NZ,DELLAYER
	RET

	DSEG
P.NUM:		DB	0
P.OFFSET:	DW	0
P.PTR:		DW	0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = RECEIVERS

	CSEG
	PUBLIC	LISTEN
	EXTRN	MOUSEX,MOUSEY,PSELECT,PTRHL,PTRCALL

LISTEN:	LD	(L.RCV),DE
L.BEGIN:CALL	PSELECT
	CP	KB_ESC			;USER PRESS ESC, RETURN WITH Z=1
	RET	Z

	CP	MS_BUTTON1
	JR	Z,L.SEARCH
	CP	MS_BUTTON2
	JR	Z,L.SEARCH
	EX	AF,AF'
	LD	A,(MOUSEX)		;IF THE EVENT IS NOT A MOUSE CLICK
	LD	H,A			;TAKE THE COORDENATES FROM ACTUAL
	LD	A,(MOUSEY)		;MOUSE PARAMETERS
	LD	L,A
	EX	AF,AF'

L.SEARCH:
	LD	(L.PAR),HL
	LD	(L.EVENT),A
	LD	E,L
	LD	D,H
	LD	HL,(L.RCV)

L.LOOP:	LD	A,(HL)			;0 MARKS END OF RECEIVERS
	OR	A
	JR	Z,L.BEGIN

	LD	(L.PTR),HL		;CHECK IF THE MOUSE POSITION IS INSIDE
	CP	D			;OF ACTUAL ELEMENT OF RECEIVER
	JR	NC,L.END
	INC	HL
	ADD	A,(HL)
	CP	D
	JR	C,L.END
	INC	HL
	LD	A,(HL)
	CP	E
	JR	NC,L.END
	INC	HL
	ADD	A,(HL)
	CP	E
	JR	C,L.END

	INC	HL			;IT IS THE RECEIVER, SO JUMP TO IT
	CALL	PTRHL
	LD	A,(L.EVENT)
	LD	DE,(L.PAR)
	CALL	PTRCALL
	OR	1			;SET Z=0
	RET

L.END:	LD	HL,(L.PTR)
	LD	BC,6
	ADD	HL,BC
	JR	L.LOOP

	DSEG
L.RCV:	DW	0
L.EVENT:DB	0
L.PTR:	DW	0
L.PAR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG
	PUBLIC	PALEVENT
	EXTRN	CARTPAGE,SETPAL

PALEVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENT PALETE NUMBER
	JR	NZ,P.DEC
	LD	A,(EDPAL)
	CP	NR_PALETES-1
	RET	Z
	INC	A
	JR	P.RET

P.DEC:	CP	MS_BUTTON2
	RET	NZ
	LD	A,(EDPAL)
	OR	A			;BUTTON 2 DECREMENT PALETE NUMBER
	RET	Z
	DEC	A
P.RET:	LD	(EDPAL),A

GAMEPAL:LD	E,LEVELPAGE
	CALL	CARTPAGE

	LD	DE,(EDPAL)
	CALL	GETPAL
	JP	SETPAL			;LOAD THE SELECTED PALETE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = EVENT

	CSEG
	PUBLIC	SETEVENT
	EXTRN	LDPATSET

SETEVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENT SET NUMBER
	JR	NZ,S.DEC
	LD	A,(EDSET)
	CP	NR_PATSET-1
	RET	Z
	INC	A
	JR	S.RET

S.DEC:	CP	MS_BUTTON2
	RET	NZ
	LD	A,(EDSET)
	OR	A			;BUTTON 2 DECREMENT SET NUMBER
	RET	Z
	DEC	A
S.RET:	LD	(EDSET),A
	LD	E,A			;THERE IS A SET CHANGE, SO UPDATE
	JP	LDPATSET		;THE GRAPHICS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	DSEG
	PUBLIC	EDLEVEL,EDROOM,EDTILE,EDFLOOR,EDPAL,EDSET,EDFLOOR
EDROOM:	DW	0
EDPAL:	DB	0
EDSET:	DB	0
EDFLOOR:DB	0
EDTILE:	DB	0
EDLEVEL:DW	0

