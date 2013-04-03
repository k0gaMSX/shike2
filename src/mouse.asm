
	INCLUDE	BIOS.INC
	INCLUDE	SHIKE2.INC
	INCLUDE	SPRITE.INC
	

MOUSECOL	EQU	15

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	INITMOUSE
	EXTRN	SPRITE,SETCOLSPR

MOUSE1	EQU	12			;DEVICE ID FOR MOUSE 1
MOUSE2	EQU	16			;DEVICE ID FOR MOUSE 2

INITMOUSE:
	LD	HL,8080H
	LD	(BUTTON1),HL
	LD	(BUTTON1OLD),HL		;MARK ALL BUTTON AS NO PRESSED

	LD	A,MOUSEPAT
	LD	(PATTERN),A
	LD	C,A
	LD	DE,PATDATA
	LD	B,4
	CALL	SPRITE

	LD	C,MOUSESPR
	LD	E,MOUSECOL
	LD	B,4
	CALL	SETCOLSPR

	LD	A,1
	LD	(TRIGGER),A
	LD	A,MOUSE1
	LD	(PORT),A
	CALL	ISCONN			;IS IT CONNECTED?
	RET	NZ

	LD	A,2
	LD	(TRIGGER),A
	LD	A,MOUSE2
	LD	(PORT),A
	CALL	ISCONN			;IS IT CONNECTED?
	RET	NZ

	XOR	A
	LD	(PORT),A
	RET


PATDATA:
P.LUP:	DB	0F0H,0E0H,0F0H,0B8H,010H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


P.RUP:	DB	078H,038H,078H,0E8H,040H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

P.LDOWN:DB	010H,0B8H,0F0H,0E0H,0F0H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H


P.RDOWN:DB	040H,0E8H,078H,038H,078H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H
	DB	000H,000H,000H,000H,000H,000H,000H,000H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = MOUSE PORT
;OUTPUT:ZF = 1 WHEN IT IS NOT CONNECTED

	CSEG

ISCONN:	LD	B,3
	LD	E,A

I.LOOP:	PUSH	DE			;READ THE MOUSE INCREMENT
	PUSH	BC			;IF YOU GET XINC=1 AT LEAST

	LD	A,E			;3 TIMES, WE CAN THINK IT IS
	PUSH	AF			;DISCONNECTED
	CALL	GTPAD
	POP	AF
	INC	A
	CALL	GTPAD
	POP	BC
	POP	DE

	CP	1
	RET	NZ
	EI
	HALT
	DJNZ	I.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = 0 DISABLE MOUSE, A = 1 ENABLE MOUSE

	CSEG
	PUBLIC	MOUSE
	EXTRN	HIDESPRITE

MOUSE:	LD	(ENABLE),A
	OR	A
	RET	NZ
	LD	C,MOUSESPR
	JP	HIDESPRITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	MOUSEHOOK
	EXTRN	SEXPAND,PUTSPRITE

MOUSEHOOK:
	LD	A,(ENABLE)
	OR	A
	RET	Z
	LD	A,(PORT)
	OR	A
	RET	Z
	CALL	GTPAD			;CHECK MOUSE POSITION
	LD	HL,(X)
	LD	H,0
	LD	DE,(SAVEX)
	CALL	SEXPAND			;CONVERT X INCREMENT TO 16 BITS
	ADD	HL,DE
	LD	DE,255
	CALL	ADJUST			;CHECK CORRECT POSITION
	LD	(X),A

	LD	HL,(Y)
	LD	H,0
	LD	DE,(SAVEY)
	CALL	SEXPAND			;CONVERT Y INCREMENT TO 16 BITS
	ADD	HL,DE
	LD	DE,211
	CALL	ADJUST			;CHECK CORRECT POSITION
	LD	(Y),A

	LD	DE,(COORD)
	LD	A,(PATTERN)
	LD	B,A
	LD	C,MOUSESPR
	CALL	PUTSPRITE		;SHOW THE MOUSE LOCATION

	LD	HL,(BUTTON1)		;MOVE ACTUAL BUTTON STATE TO OLD
	LD	(BUTTON1OLD),HL

	LD	A,(TRIGGER)
	PUSH	AF
	CALL	GTRIG			;GET BUTTON 1 STATE
	AND	80H
	LD	(BUTTON1),A
	LD	B,1
	LD	C,A
	LD	A,(BUTTON1OLD)
	XOR	C
	CALL	NZ,ADDEVENT

	POP	AF
	INC	A
	INC	A
	CALL	GTRIG			;GET BUTTON 2 STATE
	AND	80H
	LD	(BUTTON2),A
	LD	B,2
	LD	C,A
	LD	A,(BUTTON2OLD)
	XOR	C
	CALL	NZ,ADDEVENT
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = COORDENATE
;	DE = LIMIT
;OUTPUT:A = ADJUSTED COORDENATED

	CSEG

ADJUST:	LD	A,H
	BIT	7,H
	JR	NZ,A.NEG

	CALL	DCOMPR
	JP	NC,A.BIG
	LD	A,L
	RET

A.NEG:	XOR	A
	RET

A.BIG:	LD	A,E
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	B = BUTTON NUMBER
;	C = BUTTON STATE
;	
	CSEG
	EXTRN	ADDAHL

ADDEVENT:
	LD	A,C			;SET UPPER BIT = 1 WHEN RELEASING
	OR	B	
	LD	E,A
	LD	BC,(MOUSEQUEUE)		;C = IN, B = OUT
	LD	A,C
	INC	A
	AND	NR_MOUSEBUF - 1		;NR_MOUSEBUF MUST BE A POWER OF 2
	CP	B
	RET	Z			;NO ROOM FOR NEW MOUSE EVENT

	EX	AF,AF'			;SAVE NEXT POSITION
	LD	A,C
	ADD	A,A
	ADD	A,C
	LD	HL,MOUSEBUF
	CALL	ADDAHL
	LD	(HL),E			;STORE BUTTON NUMBER
	INC	HL
	LD	DE,(COORD)
	LD	(HL),E			;STORE Y
	INC	HL
	LD	(HL),D			;STORE X

	EX	AF,AF'			;RESTORE NEXT POSITION
	LD	C,A
	LD	(MOUSEQUEUE),BC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:A = BUTTON NUMBER (UPPER BIT=1 WHEN RELEASING). A = 0 WHEN NO EVENT
;	HL = MOUSE COORDENATES
;	Z = 1 WHEN NO HIT

	CSEG
	PUBLIC	MSHIT
	EXTRN	ADDAHL

MSHIT:	DI
	LD	BC,(MOUSEQUEUE)	;C = IN, B = OUT
	LD	A,B
	CP	C
	JR	NZ,E.GET
	EI
	XOR	A		;NO DATA IN THE QUEUE
	RET			;Z FLAG IS RESET

E.GET:	LD	HL,MOUSEBUF
	LD	A,B
	ADD	A,A
	ADD	A,B
	CALL	ADDAHL		;POINT THE CORRECT BYTE IN THE QUEUE
	LD	A,B
	INC	A
	AND	NR_MOUSEBUF - 1	;NR_MOUSEBUF MUST BE A POWER OF 2
	LD	B,A		;UPDATE THE OUT COUNTER
	LD	(MOUSEQUEUE),BC
	LD	A,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	OR	A		;SET Z FLAG
	EI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:A = BUTTON NUMBER (UPPER BIT=1 WHEN RELEASING). A = 0 WHEN NO EVENT
;	HL = MOUSE COORDENATES

	CSEG
	PUBLIC	MEVENT

MEVENT:	CALL	MSHIT
	RET	NZ
	EI			;SLEEP A FRAME
	HALT			;AND TRY AGAIN
	JR	MEVENT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:A = BUTTON NUMBER (UPPER BIT=1 WHEN RELEASING). A = 0 WHEN NO EVENT
;	HL = MOUSE COORDENATES

	CSEG
	PUBLIC	MPRESS

MPRESS:	CALL	MEVENT
	BIT	7,A
	JR	NZ,MPRESS      ;KEY RELEASE, WE ONLY WANT PRESS
	RET



	DSEG
ENABLE:		DB	0
PORT:		DB	0
TRIGGER:	DB	0
PATTERN:	DB	0
COORD:
Y:		DB	0
X:		DB	0
BUTTON1:	DB	0
BUTTON2:	DB	0
BUTTON1OLD:	DB	0
BUTTON2OLD:	DB	0
MOUSEQUEUE:	DW	0
MOUSEBUF:	DS	NR_MOUSEBUF*3

