	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: 	E = KEYCODE + UPPER BIT (UP/DOWN)

	CSEG
	EXTRN	ADDAHL

ADDKEY:	LD	BC,(KBDQUEUE)	; C = IN, B = OUT
	LD	A,C
	INC	A
	AND	NR_KEYBUF - 1	;NR_KEYBUF MUST BE A POWER OF 2
	CP	B
	RET	Z		;NO ROOM FOR NEW KEYCODE

	EX	AF,AF'		;SAVE NEXT POSITION
	LD	A,C
	LD	HL,KBDBUF
	CALL	ADDAHL
	LD	(HL),E		;STORE KEYCODE
	EX	AF,AF'		;RESTORE NEXT POSITION
	LD	C,A
	LD	(KBDQUEUE),BC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:      A = KEYCODE OR 0 IF EMPTY QUEUE

	CSEG
	PUBLIC	KBHIT
	EXTRN	ADDAHL

KBHIT:	DI
	LD	BC,(KBDQUEUE)	;C = IN, B = OUT
	LD	A,B
	CP	C
	JR	NZ,G.GET
	EI
	XOR	A		;NO DATA IN THE QUEUE
	RET			;Z FLAG IS RESET

G.GET:	LD	HL,KBDBUF
	LD	A,B
	CALL	ADDAHL		;POINT THE CORRECT BYTE IN THE QUEUE
	LD	A,B
	INC	A
	AND	NR_KEYBUF - 1	;NR_KEYBUF MUST BE A POWER OF 2
	LD	B,A		;UPDATE THE OUT COUNTER
	LD	(KBDQUEUE),BC
	LD	A,(HL)
	OR	A		;SET Z FLAG
	EI
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:	A = KEYCODE

	CSEG
	PUBLIC	KPRESS,KEVENT

KEVENT:	CALL	KBHIT
	RET	NZ
	EI			;SLEEP A FRAME
	HALT			;AND TRY AGAIN
	JR	KEVENT

KPRESS:	CALL	KEVENT
	BIT	7,A
	JR	NZ,KPRESS      ;KEY RELEASE, WE ONLY WANT PRESS
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OUTPUT:A = ASCII CODE

	CSEG
	PUBLIC	GETCH
	EXTRN	ADDAHL

GETCH:	CALL	KPRESS
	LD	HL,KMATRIX
	DEC	A
	CALL	ADDAHL
	LD	A,(HL)
	OR	A
	JR	Z,GETCH
	RET

;;;JAPANESSE KEY MATRIX

KMATRIX:DB	'7','6','5','4','3','2','1','0'		;ROW 0
	DB	  0,  0,"'",  0,  0,'-','9','8'		;ROW 1
	DB	'B','A',  0,  0,  0,  0,  0,  0		;ROW 2
	DB	'J','I','H','G','F','E','D','C'		;ROW 3
	DB	'R','Q','P','O','N','M','L','K'		;ROW 4
	DB	'Z','Y','X','W','V','U','T','S'		;ROW 5
	DB	  0,  0,  0,  0,  0,  0,  0,  0		;ROW 6
	DB	 10,  0,  8,  0,  9,  0,  0,  0		;ROW 7
	DB	  0,  0,  0,  0,  0,  0,  0,' '		;ROW 8
	DB	  0,  0,  0,  0,  0,  0,  0,  0		;ROW 9
	DB	  0,  0,  0,  0,  0,  0,  0,  0		;ROW 10
	DB	  0,  0,  0,  0,  0,  0,  0,  0		;ROW 11


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = XOR`ED KEYBOARD STATUS
;	B = KEYBOARD STATUS
;	C = INITIAL KEYCODE

	CSEG

SCANROW:SLA	A
	JR	NC,S.NOBIT	;IS IT ACTIVATED THE XOR'ED BIT?
	PUSH	AF
	LD	A,B
	AND	80H		;SET/RESET UPPER BIT
	OR	C
	EXX
	LD	E,A
	CALL	ADDKEY
	EXX
	POP	AF

S.NOBIT:RET	Z		;NO MORE ACTIVATED BITS IN THE XOR'ED
	INC	C
	SLA	B
	JR	SCANROW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	KBDCLR

KBDCLR:	LD	HL,0
	LD	(KBDQUEUE),HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
        PUBLIC	KBDHOOK

KBDHOOK:LD	HL,NEWKEY
	LD	DE,KBDOLD
	LD	B,11
	LD	C,1

K.LOOP:	PUSH	BC
	LD	B,(HL)
	LD	A,(DE)
	XOR	B
	CALL	NZ,SCANROW
	INC	HL
	INC	DE
	POP	BC			;CHECK NEXT ROW
	LD	A,8
	ADD	A,C
	LD	C,A
	DJNZ	K.LOOP

	LD	HL,NEWKEY		;UPDATE OUR COPY OF PREVIOUS MATRIX
	LD	DE,KBDOLD
	LD	BC,11
	LDIR
	RET

	DSEG
KBDQUEUE:	DW	0		;QUEUE POINTER
KBDOLD:		DS	11		;OLD MATRIX STATUS
KBDBUF:		DS	NR_KEYBUF	;QUEUE BUFFER

