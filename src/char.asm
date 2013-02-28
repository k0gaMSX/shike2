	INCLUDE	BIOS.INC
	INCLUDE	KBD.INC
	INCLUDE	SHIKE2.INC
	INCLUDE GEOMETRY.INC

NR_CHARS	EQU	8		;NUMBER OF CHARACTERS IN THE FULL GAME

;CHARACTER COORDENATES HAVE THE FORM (MAP,SCR,X,Y)

CHAR.MAP	EQU	0		;MAP POSITION. -1 MEANS IT IS FREE
CHAR.SCR	EQU	1		;SCREEN POSITION
CHAR.Y		EQU	2		;Y COORDENATE
CHAR.X		EQU	3		;X COORDENATE
CHAR.Z		EQU	4		;Z COORDENATE
CHAR.YR		EQU	5		;Y RENDER COORDENATE
CHAR.XR		EQU	7		;X RENDER COORDENATE
CHAR.DIR	EQU	9		;DIRECTION OF THE CHARACTER
CHAR.DIRSTEP	EQU	10		;DIRECTION OF NEXT STEP
CHAR.DIRCNT	EQU	11		;COUNTER USED FOR ANIMATIONS
CHAR.CONTROL	EQU	12		;CONTROLLER FOR THE CHARACTER
CHAR.MOB	EQU	14		;ACTUAL MOB USED
CHAR.PAT	EQU	15		;PATTERN OF THE CHARACTER
CHAR.SIZ	EQU	16

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
	XOR	A
	LD	(N.MOB),A

	LD	HL,I.INIT
	CALL	FOREACH

	LD	DE,KEYBOARD
	CALL	NEWCHAR

	LD	DE,DUMMY
	JP	NEWCHAR

I.INIT:	LD	(IX+CHAR.DIRSTEP),D.NODIR
	LD	(IX+CHAR.MAP),-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = CONTROLLER FUNCTION

	CSEG
	PUBLIC	NEWCHAR

NEWCHAR:LD	IX,BUFFER
	LD	B,NR_CHARS
	LD	A,-1
	EX	DE,HL

N.LOOP:	CP	(IX+CHAR.MAP)
	JR	Z,N.FOUND
	LD	DE,CHAR.SIZ
	ADD	IX,DE
	DJNZ	N.LOOP
	LD	HL,0
	RET				;TODO: HANDLE OVERRUN

N.FOUND:LD	(IX+CHAR.MAP),0		;REMOVE FROM FREE LIST
	LD	(IX+CHAR.CONTROL),L	;ASSIGN CONTROLLER
	LD	(IX+CHAR.CONTROL+1),H
	LD	A,(N.MOB)
	LD	(IX+CHAR.MOB),A		;ASSIGN MOB
	INC	A
	LD	(N.MOB),A
	LD	D,(IX+CHAR.X)
	LD	E,(IX+CHAR.Y)
	LD	BC,CENTRAL.P1
	CALL	WRLD2SCR		;INITIALIZE RENDER COORDENATES
	LD	(IX+CHAR.XR),L
	LD	(IX+CHAR.XR+1),H
	LD	(IX+CHAR.YR),E
	LD	(IX+CHAR.YR+1),D	;UPDATE THE CHAR IN SCREEN
	CALL	UPDATE
	LD	L,IXL
	LD	H,IXU
	RET

	DSEG
N.MOB:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	CHARACTERS
	EXTRN	HEIGTH,PTRCALL,MOVEUC,WRLD2SCR

CHARACTERS:
	LD	HL,C.ACTION
	JP	FOREACH

;

C.ACTION:
	LD	A,-1				;SKIP FREE CHARACTERS
	CP	(IX+CHAR.MAP)
	RET	Z

	LD	A,(IX+CHAR.DIRCNT)		;IS IT DOING A STEP?
	OR	A
	JR	NZ,STEP

C.CONTROL:
	LD	L,(IX+CHAR.CONTROL)		;JUMP TO THE CONTROLLER
	LD	H,(IX+CHAR.CONTROL+1)
	CALL	PTRCALL

	LD	A,(IX+CHAR.DIRSTEP)		;IS THERE A NEW DIRECTION?
	CP	D.NODIR
	RET	Z
	LD	D,(IX+CHAR.X)
	LD	E,(IX+CHAR.Y)

	LD	A,(IX+CHAR.DIRSTEP)		;TRY MOVE THE CHARACTER
	CALL	MOVEUC
	LD	A,-1				;AND CHECK THE LIMITS
	CP	D
	JR	Z,STOP
	CP	E
	JR	Z,STOP
	LD	A,MAXISOX
	CP	D
	JR	Z,STOP
	LD	A,MAXISOY
	CP	E
	JR	Z,STOP

	EXTRN	HGTHMATRIX
	LD	(C.COORD),DE
	LD	BC,HGTHMATRIX			;TODO: REMOVE THIS REFERENCE
	CALL	HEIGTH
	CP	(IX+CHAR.Z)
	JR	NZ,STOP				;DIFFERENT HEIGTH

	LD	DE,(C.COORD)
	LD	A,4				;IT IS A GOOD MOVEMENT
	LD	(IX+CHAR.DIRCNT),A
	LD	L,(IX+CHAR.Y)
	LD	H,(IX+CHAR.X)
	LD	(IX+CHAR.X),D
	LD	(IX+CHAR.Y),E

	EX	DE,HL
	LD	BC,CENTRAL.P1
	CALL	WRLD2SCR			;TRANSFORM COORDENATES
	LD	(IX+CHAR.XR),L
	LD	(IX+CHAR.XR+1),H
	LD	(IX+CHAR.YR),E
	LD	(IX+CHAR.YR+1),D		;AND NOW MOVE YOURSELF!!!!
	;CONTINUE IN STEP

	DSEG
C.COORD:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG

STEP:	DEC	(IX+CHAR.DIRCNT)
	LD	A,(JIFFY)		;USE JIFFY COUNTER FOR ANIMATIONS
	SRL	A
	SRL	A
	AND	3
	CP	3
	JR	NZ,S.1
	XOR	A
S.1:	LD	L,(IX+CHAR.DIRSTEP)	;UPDATE ACTUAL DIR OF THE CHARACTER
	LD	(IX+CHAR.DIR),L
	JR	UPDATE

;

STOP:	LD	(IX+CHAR.DIRSTEP),D.NODIR
	XOR	A
	LD	(IX+CHAR.DIRCNT),A
	;CONTINUE IN UPDATE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO THE CHARACTER
;	A = FRAME ANIMATION

	CSEG
	EXTRN	MOV16ISO,PUTMOB

UPDATE:	PUSH	AF
	LD	A,(IX+CHAR.DIRSTEP)
	LD	L,(IX+CHAR.XR)
	LD	H,(IX+CHAR.XR+1)
	LD	E,(IX+CHAR.YR)
	LD	D,(IX+CHAR.YR+1)
	CALL	MOV16ISO		;CALCULATE NEXT RENDER COORDENATES
	LD	(IX+CHAR.XR),L
	LD	(IX+CHAR.XR+1),H
	LD	(IX+CHAR.YR),E
	LD	(IX+CHAR.YR+1),D
	POP	AF

	ADD	A,A			;CALCULATE FRAME COORDENATES
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,(IX+CHAR.PAT)
	ADD	A,(IX+CHAR.DIR)
	LD	B,A
	LD	C,(IX+CHAR.MOB)
	PUSH	IX
	CALL	PUTMOB			;RENDER THE CHARACTER
	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG
	EXTRN	GETCH,KEY2DIR,EXIT

KEYBOARD:
	CALL	GETCH
	RET	Z				;NO NEW KEY

	BIT	7,A
	JR	NZ,K.RELEASE			;IT IS A RELEASE KEY

	PUSH	AF				;SAVE THE KEY
	CALL	KEY2DIR
	JR	C,K.SYSTEM

	LD	(IX+CHAR.DIRSTEP),A
	POP	AF
	LD	(K.KEY),A
	RET

K.SYSTEM:					;IT IS NOT A DIRECTIONAL KEY
	POP	AF				;TODO: MOVE TO OTHER PLACE
	CP	KB_ESC
	CALL	Z,EXIT
	RET

K.RELEASE:
	AND	7FH
	LD	HL,K.KEY
	CP	(HL)
	JP	Z,STOP				;PUT THE STOP ANIMATION
	RET

	DSEG
K.KEY:		DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG

DUMMY:	LD	A,(IX+CHAR.DIR)
	CP	D.UP
	JR	Z,D.Y
	CP	D.DOWN
	JR	Z,D.Y

	LD	A,(IX+CHAR.X)
	CP	MAXISOX-1
	JR	Z,D.CHANGE
	CP	0
	JR	Z,D.CHANGE
	CP	MAXISOX/2
	JR	Z,D.RAND
	RET

D.Y:	LD	A,(IX+CHAR.Y)
	CP	MAXISOY-1
	JR	Z,D.CHANGE
	CP	0
	JR	Z,D.CHANGE
	CP	MAXISOY/2
	JR	Z,D.RAND
	RET

D.RAND:	LD	A,R
	AND	3
	RET	Z

D.CHANGE:
	LD	A,R
	AND	3
	LD	(IX+CHAR.DIRSTEP),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
BUFFER:	DS	CHAR.SIZ * NR_CHARS
