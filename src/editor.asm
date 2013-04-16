
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	EDINIT
	EXTRN	MOUSE,MSCLR,CLRVPAGE

EDINIT:	LD	E,EDPAGE
	CALL	CLRVPAGE
	CALL	GAMEPAL

	LD	A,(EDSET)
	LD	E,A
	CALL	LOADSET			;LOAD GRAPHICS FOR SELECTED SET

	LD	A,1
	CALL	MOUSE
	JP	MSCLR

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = PATTERN NUMBER
;OUTPUT:HL = COORDENATES OF THE PATTERN

	CSEG

PAT2XY:	LD	A,E
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = POINTER TO FIRST STACK
;	E = NUMBER OF STACKS
;	BC = SCREEN COORDENATES

	CSEG
	PUBLIC	DRAWSTACKS

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = PATTERN STACK
;	BC = SCREEN COORDINATES

	CSEG
	EXTRN	VDPPAGE,LMMM

PSTACK:	EX	DE,HL
	LD	(P.COORD),BC
	LD	A,PATPAGE
	LD	(VDPPAGE),A
	LD	A,LOGTIMP
	LD	(LOGOP),A

	LD	B,NR_LAYERS

P.LOOP:	LD	A,(HL)			;0 MARKS THE END OF A TILE STACK
	OR	A
	RET	Z

	PUSH	HL
	PUSH	BC
	LD	E,A
	CALL	PAT2XY			;TRANSFORM THE PATTER NUMBER TO XY
	LD	DE,(P.COORD)
	LD	BC,1008H
	CALL	LMMM			;AND COPY THE PATTERN TO THE DESTINE
	POP	BC
	POP	HL
	INC	HL
	DJNZ	P.LOOP
	RET

	DSEG
P.COORD:DW	0

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
	LD	A,(P.NUM)
	JR	NZ,P1.1

	CP	NR_LAYERS
	CALL	NZ,SELPAT
	LD	DE,(P.NUM)
	LD	D,A
	LD	BC,(P.OFFSET)
	LD	HL,(P.PTR)
	CALL	NZ,ADDLAYER
	RET

P1.1:	OR	A			;MOUSE 2 DELETES A PATTERN
	LD	E,A
	LD	BC,(P.OFFSET)
	LD	HL,(P.PTR)
	CALL	NZ,DELLAYER
	RET

	DSEG
P.NUM:		DB	0
P.OFFSET:	DW	0
P.PTR:		DW	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = SET NUMBER

	CSEG
	PUBLIC	LOADSET
	EXTRN	VLDIR,CARTPAGE

LOADSET:LD	A,SET0PAGE
	ADD	A,E
	LD	E,A
	CALL	CARTPAGE		;SET THE PAGE OF THE GRAPHICS
	LD	HL,CARTSEG
	LD	DE,00000H
	LD	BC,04000H
	LD	A,PATPAGE*2
	JP	VLDIR			;COPY THEM TO VRAM (256*128)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = RECEIVERS

	CSEG
	PUBLIC	LISTEN
	EXTRN	PSELECT,PTRHL,PTRCALL

LISTEN:	LD	(L.RCV),DE
L.BEGIN:CALL	PSELECT
	CP	KB_ESC			;USER PRESS ESC, RETURN WITH Z=1
	RET	Z

	CP	MS_BUTTON1
	JR	Z,L.SEARCH
	CP	MS_BUTTON2
	JR	NZ,L.BEGIN		;UNEXPECTED EVENT GO TO BEGIN

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
	LD	A,(EDPAL)
	JR	NZ,P.DEC
	CP	NR_PALETES-1
	RET	Z
	INC	A
	JR	P.RET

P.DEC:	OR	A			;BUTTON 2 DECREMENT PALETE NUMBER
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

SETEVENT:
	CP	MS_BUTTON1		;BUTTON 1 INCREMENT SET NUMBER
	LD	A,(EDSET)
	JR	NZ,S.DEC
	CP	NR_PATSET-1
	RET	Z
	INC	A
	JR	S.RET

S.DEC:	OR	A			;BUTTON 2 DECREMENT SET NUMBER
	RET	Z
	DEC	A
S.RET:	LD	(EDSET),A
	LD	E,A			;THERE IS A SET CHANGE, SO UPDATE
	JP	LOADSET			;THE GRAPHICS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	DSEG
	PUBLIC	EDLEVEL,EDROOM,EDTILE,EDFLOOR,EDPAL,EDSET,EDFLOOR
EDROOM:	DB	0
EDPAL:	DB	0
EDSET:	DB	0
EDFLOOR:DB	0
EDTILE:	DB	0
EDLEVEL:DB	0

