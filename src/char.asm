
	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC
	INCLUDE	EVENT.INC
	INCLUDE	LEVEL.INC
	INCLUDE	DATA.INC

CHARHEIGHT	EQU	4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	CHARINIT
	EXTRN	CARTPAGE,PLACE,ADDAHL,PTRHL,SETCAMOP

CHARINIT:
	PUSH	IX
	LD	HL,READY		;INITIALIZE THE LINKED LIST
	LD	(READY+CHAR.NEXT),HL
	LD	(READY+CHAR.PREV),HL
	LD	A,DNODIR		;INITIALIZE USER VARIABLES
	LD	(USERDIR),A
	XOR	A
	LD	(KEYDIR),A

	LD	E,LEVELPAGE		;GET CHAR INITIALIZATION DATA FROM
	CALL	CARTPAGE		;LEVEL INFO
	CALL	GETCHARS
	LD	IX,CHARBUF
	LD	B,NR_CHARS

C.LOOP:	PUSH	BC
	LD	(C.PTR),HL
	PUSH	HL
	POP	IY
	LD	A,(IY+CINFO.CONTROL)	;TRANSFORM CONTROLLER NUMBER TO FUNCTION
	LD	B,A
	ADD	A,A
	ADD	A,A
	ADD	A,B
	LD	HL,CTRL
	CALL	ADDAHL
	CALL	PTRHL
	LD	B,H
	LD	C,L
	LD	E,(IY+CINFO.PAT)	;E = PATTERN NUMBER
	CALL	CHARACTER		;INITIALIZE CHARACTER
	LD	HL,(C.PTR)
	LD	E,L
	LD	D,H
	LD	BC,CINFO.DIR
	ADD	HL,BC
	LD	C,(HL)
	CALL	PLACE			;PLACE IT IN THE MAP
	LD	DE,SIZCHAR		;NEXT CHARACTER
	ADD	IX,DE
	LD	HL,(C.PTR)
	LD	DE,SIZCINFO
	ADD	HL,DE
	POP	BC
	DJNZ	C.LOOP

	POP	IX
	RET


CTRL:	DW	DUMMY,CS.1
	DB	0
	DW	USER,CS.2
	DB	1

CS.1:	"DUMMY",0
CS.2:	"USER",0

	DSEG

C.PTR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = CHAR CONTROL FUNCTION
;	C = CHAR CONTROL CODE
;OUTPUT: Z = 1 WHEN NO DEFINITION IS FOUND
;	HL = POINTER TO CONTROL INFORMATION

	CSEG
	PUBLIC	CHARCTL
	EXTRN	PTRHL

CHARCTL:LD	IY,CTRL
	EX	DE,HL
	LD	B,NR_CHARCTL

CT.LOOP:LD	A,L
	CP	(IY+CHARCTL.FUN)
	JR	NZ,CT.CODE
	LD	A,H
	CP	(IY+CHARCTL.FUN+1)
	JR	Z,CT.OK

CT.CODE:LD	A,C
	CP	(IY+CHARCTL.CODE)
	JR	Z,CT.OK

	LD	DE,SIZCHARCTL
	ADD	IY,DE
	DJNZ	CT.LOOP
	RET

CT.OK:	PUSH	IY
	POP	HL
	OR	1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG

DUMMY:	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;	DE = HEAD OF LIST WHERE LINK

	CSEG

LINK:	LD	IYL,E			;IY = HEAD
	LD	IYU,D
	LD	L,E			;HL = HEAD
	LD	H,D
	LD	E,(IY+CHAR.NEXT)	;DE = HEAD->NEXT
	LD	D,(IY+CHAR.NEXT+1)
	LD	C,IXL
	LD	B,IXU			;BC = PTR

	LD	(IY+CHAR.NEXT),C	;HEAD->NEXT = PTR
	LD	(IY+CHAR.NEXT+1),B
	LD	IYL,E
	LD	IYU,D			;IY = HEAD->NEXT

	LD	(IX+CHAR.PREV),L
	LD	(IX+CHAR.PREV+1),H	;PTR->PREV = HEAD
	LD	(IX+CHAR.NEXT),E
	LD	(IX+CHAR.NEXT+1),D	;PTR->NEXT = HEAD->NEXT

	LD	(IY+CHAR.PREV),C
	LD	(IY+CHAR.PREV+1),B	;HEAD->NEXT->PREV = PTR
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR

	CSEG

UNLINK:	LD	C,(IX+CHAR.PREV)
	LD	B,(IX+CHAR.PREV+1)	;BC = PTR->PREV
	LD	E,(IX+CHAR.NEXT)
	LD	D,(IX+CHAR.NEXT+1)	;DE = PTR->NEXT

	LD	IYL,C			;IY = PTR->PREV
	LD	IYU,B
	LD	(IY+CHAR.NEXT),E
	LD	(IY+CHAR.NEXT+1),D	;PTR->PREV->NEXT = PTR->NEXT

	LD	IYL,E			;IY = PTR->NEXT
	LD	IYU,D
	LD	(IY+CHAR.PREV),C
	LD	(IY+CHAR.PREV+1),B	;PTR->NEXT->PREV = PTR->PREV
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHAR
;	E = PATTERN
;	BC = CONTROLLER FUNCTION

	CSEG
	EXTRN	MOVABLE

CHARACTER:
	LD	(IX+CHAR.PAT),E
	PUSH	BC
	LD	A,E			;WE HAVE 4 DIRECTIONS, SO
	ADD	A,A			;EACH PATTERN MEANS MULTIPLY BY 4
	ADD	A,A
	LD	E,A
	LD	C,CHARHEIGHT
	LD	HL,SETRDY
	CALL	MOVABLE
	POP	HL
	LD	(IX+CHAR.CONTROL),L
	LD	(IX+CHAR.CONTROL+1),H
	LD	DE,READY		;LINK IT IN READY LIST
	JP	LINK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	THINK
	EXTRN	PTRCALL

THINK:	XOR	A			;FLAG FOR READING KEYBOARD
	LD	(KBD),A
	PUSH	IX
	LD	DE,(READY+CHAR.NEXT)
	JR	T.ELOOP

T.LOOP:	LD	IXL,E
	LD	IXU,D
	LD	E,(IX+CHAR.NEXT)
	LD	D,(IX+CHAR.NEXT+1)
	PUSH	DE
	LD	L,(IX+CHAR.CONTROL)
	LD	H,(IX+CHAR.CONTROL+1)
	CALL	PTRCALL
	POP	DE

T.ELOOP:LD	HL,READY
	CALL	DCOMPR
	JR	NZ,T.LOOP

T.END:	POP	IX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	IX = POINTER TO THE CHARACTER

	CSEG

SETRDY:	LD	DE,READY
	JP	LINK


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = KEY
;OUTPUT: A = DIRECTION
;	 CY = 1 WHEN E IS NOT A DIRECTIONAL KEY

	CSEG

KEY2DIR:SUB	KB_RIGTH
	JR	C,K.NODIR
	CP	DNODIR
	JR	NC,K.NODIR
	OR	A
	RET

K.NODIR:LD	A,DNODIR
	SCF
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = CHAR NUMBER
;OUTPUT:HL = POINTER TO THE N CHAR

	CSEG
	PUBLIC	GETNCHAR
	EXTRN	MULTEA

GETNCHAR:
	LD	A,SIZCHAR
	CALL	MULTEA
	LD	DE,CHARBUF
	ADD	HL,DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: IX = POINTER TO THE CHARACTER

	CSEG
	EXTRN	EDITOR,RESETCAM,FINISH,KBHIT,STEP,MAPACTION

USER:	XOR	A			;AVOID 2 CHARS READING THE KEYBOARD
	LD	HL,KBD
	OR	(HL)
	RET	NZ
	INC	(HL)
	CALL	KBHIT
	CP	KB_ESC
	JR	NZ,U.EDIT
	LD	A,1
	LD	(FINISH),A
	RET

U.EDIT:	CP	KB_SELECT
	JR	NZ,U.TELL
	CALL	EDITOR
	JP	RESETCAM

U.TELL:	CP	KB_SPACE
	JR	NZ,U.RELSE
	CALL	MAPACTION
	RET

U.RELSE:BIT	7,A
	JR	Z,U.DIR
	AND	7FH			;REMOVE RELESE MARK
	LD	HL,KEYDIR
	CP	(HL)
	JR	NZ,U.STEP		;RELEASE OF ANOTHER KEY?
	LD	(HL),0
	LD	A,DNODIR
	LD	(USERDIR),A
	RET

U.DIR:	OR	A
	JR	Z,U.STEP		;NO KEY, TEST PREVIOUS KEY
	LD	(KEYDIR),A
	CALL	KEY2DIR			;CHECK IF THE NEW KEY IS DIRECTIONAL
	JR	C,U.STEP
	LD	(USERDIR),A

U.STEP:	LD	A,(USERDIR)		;IF KEYDIR IS NODIR THEN RETURN
	CP	DNODIR
	RET	Z
	CALL	STEP
	JP	NZ,UNLINK
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
KBD:	DB	0
USERDIR:DB	0			;LAST DIRECTION PRESSED BY USER
KEYDIR:	DB	0			;LAST DIRECTIONAL KEY PRESSED BY USER
READY:	DS	CHAR.PREV+2		;CHARACTERS READY TO RUN
CHARBUF:DS	SIZCHAR*NR_CHARS

