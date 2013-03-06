
	INCLUDE	SHIKE2.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: DE = WORD TO PACK
;OUTPUT:A = PACKED BYTE

	CSEG
	PUBLIC	PACK

PACK:	LD	A,D
	AND	0FH
	RLCA
	RLCA
	RLCA
	RLCA
	LD	D,A
	LD	A,E
	AND	0FH
	OR	D
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: A = PACKED BYTE
;	DE = UNPACKED WORD

	CSEG
	PUBLIC	UNPACK

UNPACK:	LD	D,A
	AND	0FH
	LD	E,A
	LD	A,D
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	LD	D,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = 1ST OPERAND
;	A = 2ND OPERAND
;OUTPUT:HL = DE*A

	PUBLIC	MULTDEA

MULTDEA:LD	HL,0
	LD	B,8

DE.LOOP:RRCA
	JP	NC,DE.NOT
	ADD	HL,DE
DE.NOT:	SLA	E
	RL	D
	DJNZ	DE.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT: E = 1ST OPERAND
;	A = 2ND OPERAND
;OUTPUT:HL = E*A

	PUBLIC	MULTEA

MULTEA:	LD	H,A
	LD	D,0
	LD	L,D
	LD	B,8

E.LOOP:	ADD	HL,HL
	JP	NC,E.NOT
	ADD	HL,DE
E.NOT:	DJNZ	E.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL

	PUBLIC	PTRCALL

PTRCALL:JP	(HL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL
;	A

	PUBLIC	ARYHL

ARYHL:	ADD	A,A
	CALL	ADDAHL
	;CONTINUE IN PTRHL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL
	PUBLIC	PTRHL

PTRHL:	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL
;	A
	PUBLIC	ADDAHL

ADDAHL:	ADD	A,L
	LD	L,A
	RET	NC
	INC	H
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = JUMP TABLE
;       A = ELEMENT OF THE TABLE

	PUBLIC	SWTCH

SWTCH:	CALL	ARYHL
	PUSH	HL
	EX	AF,AF'
	EXX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		A = NUMBER
;		DE = OUTPUT BUFFER

	CSEG
	PUBLIC	ITOA

ITOA:	EX	DE,HL
	LD	DE,I.POT10

I.NEXT:	EX	AF,AF'
	LD	A,(DE)
	OR	A
	RET	Z		;0 MARKS END OF POT10 ARRAY
	LD	B,A
	LD	C,'0'
        EX	AF,AF'

I.LOOP:	SUB	B
	JR	C,I.BIGGER
	INC	C
	JR	I.LOOP

I.BIGGER:			;THE POT10 ELEMENT IS BIGGER THAN OUR NUMBER
	ADD	A,B		;SO RESTORE VALUE AND PASS TO THE NEXT ELEMENT
	LD	(HL),C
	INC	DE
	INC	HL
	JR	I.NEXT

I.END:	LD	(HL),0		;PUT END OF STRING
	RET

I.POT10:	DB	100,10,1,0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:		HL = ADDRESS WHERE WRITE 0
;		BC = NUMBER OF BYTES
;		A = BYTE TO WRITE (IN THE CASE OF MEMSET)
	CSEG
	PUBLIC	BZERO,MEMSET

BZERO:	XOR	A
MEMSET:	LD	E,L
	LD	D,H
	INC	DE
	DEC	BC
	LD	(HL),A
	LD	A,B
	OR	C
	RET	Z
	LDIR
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = LOCATION WHERE WE WANT TO PUT THE CURSOR (IN FONT UNITS)

	CSEG
	PUBLIC	LOCATE

LOCATE:	LD	A,D
	ADD	A,A
	ADD	A,A
	LD	D,A
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	(CURSOR),DE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POINTER TO ASCIINUL STRING

	CSEG
	PUBLIC	PUTS

PUTS:	LD	A,(DE)
	OR	A
	RET	Z
	INC	DE
	PUSH	DE
	CALL	PUTCHAR
	POP	DE
	JR	PUTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = ASCII CODE

	CSEG
	PUBLIC	PUTCHAR
	EXTRN	VDPPAGE,HMMM

PUTCHAR:CP	10		;NEW LINE?
	JR	NZ,P.TAB
	LD	HL,(CURSOR)
	LD	H,0
	LD	A,8
	ADD	A,L
	LD	L,A
	LD	(CURSOR),HL
	RET

P.TAB:	CP	9		;TABULATION?
	JR	NZ,P.NL
P.TLOOP:LD	A,' '		;PRINT SPACES UNTIL WE ARE IN 8 COLUMN (8*4=32)
	CALL	PUTCHAR
	LD	DE,(CURSOR)
	LD	A,31
	AND	D
	JR	NZ,P.TLOOP
	RET

P.NL:	CP	31		;SMALLER THAN SPACE?
	RET	C

	CP	95		;BIGGER THAN _?
	RET	NC

	SUB	32		;REMOVE ASCII OFFSET
	ADD	A,A
	ADD	A,A		;CALCULATE X COORDENATE FOR THE COPY

	LD	H,A
	LD	L,FONTY
	LD	A,FONTPAGE
	LD	(VDPPAGE),A
	LD	DE,(CURSOR)
	LD	BC,4*256 + 8
	PUSH	DE
	CALL	HMMM
	POP	DE
	LD	A,4
	ADD	A,D
	LD	D,A
	LD	(CURSOR),DE
	RET

	DSEG
CURSOR:	DW	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = POINTER TO FORMAT STRING
;	(SP-2) ... = ARGUMENTS


	CSEG
	PUBLIC	PRINTF

PRINTF:	POP	HL
	LD	(P.RET),HL		;SAVE THE RETURN ADDRESS

P.LOOP:	LD	A,(DE)
	INC	DE
	OR	A
	JR	NZ,P.NEXT
	LD	HL,(P.RET)		;RETURN TO SAVED ADDRESS
	JP	(HL)

P.NEXT:	PUSH	DE
	CP	'%'
	JR	Z,P.FORMAT
	CALL	PUTCHAR			;PRINT THE CHARACTER
	JR	P.END

P.FORMAT:
	XOR	A
	LD	(P.PAD),A
	POP	DE
	POP	HL
	LD	A,(DE)			;TAKE FORMAT
	INC	DE
	CP	'0'			;0 MEANS ADD PADDING TO THE NUMBER
	JR	NZ,P.F1
	LD	A,1
	LD	(P.PAD),A
	LD	A,(DE)
	INC	DE
P.F1:	PUSH	DE

	CP	's'			;STRING?
	JR	NZ,P.CHAR
	EX	DE,HL
	CALL	PUTS
	JR	P.END

P.CHAR:	CP	'c'			;CHARACTER?
	JR	NZ,P.INT
	LD	A,L
	CALL	PUTCHAR
	JR	P.END

P.INT:	CP	'd'			;DECIMAL?
	JR	NZ,P.END
	LD	A,L
	LD	DE,P.BUF
	CALL	ITOA
	CALL	SKIP
	CALL	PUTS

P.END:	POP	DE
	JR	P.LOOP

;;;;;;

SKIP:	LD	DE,P.BUF		;SKIP ALL THE '0' IN P.BUF
	LD	A,(P.PAD)
	OR	A
	RET	NZ

S.LOOP:	LD	A,(DE)
        OR	A
	JR	NZ,S.0
	DEC	DE			;END OF STRING, DECREMENT ONE
	RET

S.0:	CP	'0'
	RET	NZ
	INC	DE
	JR	S.LOOP

	DSEG
P.RET:	DW	0
P.BUF:	DS	4
P.PAD:	DB	0


