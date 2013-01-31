	INCLUDE	KBD.INC
	INCLUDE GEOMETRY.INC

NR_CHARS	EQU	8		;NUMBER OF CHARACTERS IN THE FULL GAME

MAXX		EQU	16
MAXY		EQU	16

;CHARACTER COORDENATES HAVE THE FORM (MAP,SCR,X,Y)

CHAR.MAP	EQU	0		;MAP POSITION. -1 MEANS IT IS FREE
CHAR.SCR	EQU	1		;SCREEN POSITION
CHAR.Y		EQU	2		;Y COORDENATE
CHAR.X		EQU	3		;X COORDENATE
CHAR.YR		EQU	4		;Y RENDER COORDENATE
CHAR.XR		EQU	6		;X RENDER COORDENATE
CHAR.DIR	EQU	8		;ACTUAL DIR
CHAR.DIRCNT	EQU	9		;COUNTER USED FOR ANIMATIONS
CHAR.SIZ	EQU	10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = FUNCTION POINTER

	CSEG
	EXTRN	PTRCALL

FOREACH:LD	IX,BUFFER
	LD	B,NR_CHARS

F.LOOP:	PUSH	BC
	PUSH	HL
	CALL	PTRCALL
	POP	HL
	POP	BC

	LD	DE,CHAR.SIZ
	ADD	IX,DE
	DJNZ	F.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITCHAR
	EXTRN	BZERO

INITCHAR:
	LD	HL,BUFFER
	LD	BC,CHAR.SIZ*NR_CHARS
	CALL	BZERO
	LD	HL,I.INIT
	CALL	FOREACH
	JP	NEWCHAR

I.INIT:	LD	(IX+CHAR.DIR),D.NODIR
	LD	(IX+CHAR.MAP),-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	NEWCHAR

NEWCHAR:LD	IX,BUFFER
	LD	B,NR_CHARS
	LD	A,-1

N.LOOP:	CP	(IX+CHAR.MAP)
	JR	Z,N.FOUND
	LD	DE,CHAR.SIZ
	ADD	IX,DE
	DJNZ	N.LOOP
	LD	HL,0
	RET				;TODO: HANDLE OVERRUN

N.FOUND:LD	(IX+CHAR.MAP),0		;REMOVE FROM FREE LIST
	LD	L,IXL
	LD	H,IXU
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	CHARACTERS

CHARACTERS:
	LD	IX,BUFFER
	;CONTINUE IN KBCONTROL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG
	EXTRN	GETCH,KEY2DIR,MOVEUC,WRLD2SCR,PUTMOB,EXIT,MOV16ISO

KBCONTROL:
	LD	A,(IX+CHAR.DIR)
	CP	D.NODIR
	JR	Z,K.GETCH
	DEC	(IX+CHAR.DIRCNT)
	JR	NZ,K.STEP

K.GETCH:LD	A,D.NODIR
	LD	(IX+CHAR.DIR),A
	CALL	GETCH
	RET	Z
	CP	KB_ESC
	CALL	Z,EXIT
	CALL	KEY2DIR
	LD	(IX+CHAR.DIR),A
	RET	C
	LD	A,4
	LD	(IX+CHAR.DIRCNT),A

K.MOVE:	LD	D,(IX+CHAR.X)
	LD	E,(IX+CHAR.Y)
	LD	(K.COORD),DE

	LD	A,(IX+CHAR.DIR)
	CALL	MOVEUC
	LD	A,-1
	CP	D
	JR	Z,K.CANCEL
	CP	E
	JR	Z,K.CANCEL

	LD	A,MAXX
	CP	D
	JR	Z,K.CANCEL
	LD	A,MAXY
	CP	E
	JR	Z,K.CANCEL

	LD	(IX+CHAR.X),D
	LD	(IX+CHAR.Y),E

	LD	DE,(K.COORD)
	LD	BC,7814H
	CALL	WRLD2SCR
	LD	(IX+CHAR.XR),L
	LD	(IX+CHAR.XR+1),H
	LD	(IX+CHAR.YR),E
	LD	(IX+CHAR.YR+1),D
	LD	A,(IX+CHAR.DIR)			;K.STEP WAIT A = DIR

K.STEP:	LD	L,(IX+CHAR.XR)
	LD	H,(IX+CHAR.XR+1)
	LD	E,(IX+CHAR.YR)
	LD	D,(IX+CHAR.YR+1)
	CALL	MOV16ISO
	LD	(IX+CHAR.XR),L
	LD	(IX+CHAR.XR+1),H
	LD	(IX+CHAR.YR),E
	LD	(IX+CHAR.YR+1),D
	LD	BC,0
	JP	PUTMOB

K.CANCEL:
	LD	(IX+CHAR.DIR),D.NODIR
	RET

	DSEG
K.COORD:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
BUFFER:	DS	CHAR.SIZ * NR_CHARS
