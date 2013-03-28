
	INCLUDE	SHIKE2.INC
	INCLUDE	BIOS.INC

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
;OUTPUT:DE = UNPACKED WORD

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

	CSEG
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

	CSEG
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

	CSEG
	PUBLIC	PTRCALL

PTRCALL:JP	(HL)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE=POINTER
;	A=INDEX
;OUTPUT:DE=DE[A*2]

	CSEG
	PUBLIC	ARYDE

ARYDE:	EX	DE,HL
	CALL	ARYHL
	EX	DE,HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL=POINTER
;	A=INDEX
;OUTPUT:HL=HL[A*2]

	CSEG
	PUBLIC	ARYHL

ARYHL:	ADD	A,A
	CALL	ADDAHL
	;CONTINUE IN PTRHL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL=POINTER
;OUTPUT:HL=*HL

	CSEG
	PUBLIC	PTRHL

PTRHL:	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE
;OUTPUT:DE=*DE

	CSEG
	PUBLIC	PTRDE

PTRDE:	EX	DE,HL
	CALL	PTRHL
	EX	DE,HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL=16 BIT VALUE
;	A=8 BIY VALUE
;OUTPUT:HL=HL+A

	CSEG
	PUBLIC	ADDAHL

ADDAHL:	ADD	A,L
	LD	L,A
	RET	NC
	INC	H
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = JUMP TABLE
;       A = ELEMENT OF THE TABLE

	CSEG
	PUBLIC	SWTCH

SWTCH:	CALL	ARYHL
	PUSH	HL
	EX	AF,AF'
	EXX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	A = CHARACTER
;OUTPUT:Z = 1 WHEN A IS NOT A CHARACTER

	CSEG
	PUBLIC	ISDIGIT

ISDIGIT:CP	'0'
	JR	Z,I.OK
	JR	C,I.NOK
	CP	'9'+1
	JR	NC,I.NOK

I.OK:	OR	1
	RET

I.NOK:	XOR	A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = INPUT STRING

	CSEG
	PUBLIC	ATOI

ATOI:	LD	B,0
A.LOOP1:LD	A,(DE)			;LOOK FOR THE FIRST CHARACTER WHICH
	CALL	ISDIGIT			;IS NOT A DIGIT
	JR	Z,A.EOS
	INC	DE
	INC	B
	JR	A.LOOP1

A.EOS:	LD	A,B			;END OF STRING
	OR	A
	RET	Z
	EX	DE,HL
	LD	E,1
	XOR	A
	LD	(A.VAL),A

A.LOOP:	DEC	HL			;VAL += (*--PTR - '0') * FACTOR
	LD	A,(HL)
	PUSH	BC
	PUSH	HL

	SUB	'0'
	CALL	MULTEA
	LD	A,(A.VAL)
	CALL	ADDAHL
	LD	A,L
	LD	(A.VAL),A

	LD	A,10			;FACTOR *= 10
	CALL	MULTEA
	LD	E,L

	POP	HL
	POP	BC
	DJNZ	A.LOOP
	LD	A,(A.VAL)
	RET

	DSEG
A.VAL:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	BC = NUMBER
;	DE = OUTPUT BUFFER

	CSEG
	PUBLIC	ITOA

ITOA:	LD	L,C		;HL = INPUT NUMBER
	LD	H,B		;DE = OUTPUT BUFFER
	LD	IY,I.POW10	;IY = POW ARRAY

I.NEXT:	LD	C,(IY)
	INC	IY
	LD	B,(IY)		;BC = FACTOR
	INC	IY
	LD	A,B
	OR	C
	JR	Z,I.END		;0 MARKS END OF POT10 ARRAY

	LD	A,'0'
I.LOOP:	OR	A
	SBC	HL,BC
	JR	C,I.BIG
	INC	A
	JR	I.LOOP

I.BIG:	ADD	HL,BC		;THE POW10 ELEMENT IS BIGGER THAN OUR NUMBER
	LD	(DE),A		;SO RESTORE VALUE AND PASS TO THE NEXT ELEMENT
	INC	DE
	JR	I.NEXT

I.END:	XOR	A
	LD	(DE),A		;PUT END OF STRING
	RET

I.POW10:DW	10000,1000,100,10,1,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	DE = INPUT STRING
;OUTPUT:A = LEN

	CSEG
	PUBLIC	STRLEN

STRLEN:	LD	L,E			;IT ASSUMES STRING OF ONLY 256 BYTES
	LD	H,D
	XOR	A
	LD	BC,0
	CPIR
	DEC	HL
	OR	A
	SBC	HL,DE
	LD	A,L
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = SOURCE ADDRESS
;	DE = DESTINE ADDRESS
;	BC = BUFFER SIZE

	CSEG
	PUBLIC	MEMMOVE,MEMCPY

MEMMOVE:CALL	DCOMPR
	JR	C,M.SMALL
MEMCPY:	LDIR
	RET

M.SMALL:EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	DEC	HL
	DEC	DE
	LDDR
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	HL = ADDRESS WHERE WRITE 0
;	BC = NUMBER OF BYTES
;	A = BYTE TO WRITE (IN THE CASE OF MEMSET)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	CLS
	EXTRN	CLRVPAGE

CLS:	LD	A,(ACPAGE)
	LD	E,A
	CALL	CLRVPAGE
	LD	DE,0

	; CONTINUE IN CLRVPAGE

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
;INPUT:	DE = POINTER TO OUTPUT BUFFER
;	 C = SIZE OF OUTPUT BUFFER

	CSEG
	PUBLIC	GETS
	EXTRN	GETCHAR,VDPSYNC

GETS:	LD	(G.PTR),DE
	LD	A,C
	LD	(G.LEN),A
	LD	(G.CNT),A

G.LOOP:	CALL	VDPSYNC
	CALL	GETCHAR
	PUSH	AF
	CALL	PUTCHAR
	POP	AF
	LD	HL,(G.PTR)
	LD	DE,(G.CNT)

	CP	10
	JR	NZ,G.BS
	LD	HL,(G.PTR)
	LD	(HL),0
	RET

G.BS:	CP	8
	JR	NZ,G.ADD
	LD	A,(G.LEN)
	CP	E
	JR	Z,G.LOOP
	INC	E
	DEC	HL
	JR	G.SET

G.ADD:	DEC	E
	JR	Z,G.LOOP
	LD	(HL),A
	INC	HL

G.SET:	LD	A,E
	LD	(G.CNT),A
	LD	(G.PTR),HL
	JR	G.LOOP

	DSEG
G.PTR:	DW	0
G.LEN:	DB	0
G.CNT:	DB	0

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
	JR	NZ,P.BS
	LD	HL,(CURSOR)
	LD	H,0
	LD	A,8
	ADD	A,L
	LD	L,A
	LD	(CURSOR),HL
	RET

P.BS:	CP	8		;BACKSPACE?
	JR	NZ,P.TAB
	LD	DE,(CURSOR)
	LD	A,D
	OR	A
	RET	Z		;COLUMN 0, RETURN

	SUB	4		;ONE LEFT
	LD	D,A
	LD	(CURSOR),DE
	PUSH	DE
	LD	A,' '		;PRINT SPACE
	CALL	PUTCHAR
	POP	DE
	LD	(CURSOR),DE
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
;INPUT:	BC = 16 BIT NUMBER
;	DE = OUTPUT BUFFER

	CSEG

HEX:	CALL	H.BYTE
	LD	C,B

H.BYTE:	LD	A,C
	AND	0F0H
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	H.NIBBLE
	LD	(DE),A
	INC	DE

	LD	A,C
	AND	0FH
	CALL	H.NIBBLE
	LD	(DE),A
	INC	DE
	RET

H.NIBBLE:
	CP	10
	JR	C,H.DEC
	SUB	10
	ADD	A,'A'
	RET

H.DEC:	ADD	A,'0'
	RET

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
	JR	NZ,P.HEX
	LD	C,L
	LD	B,H
	LD	DE,P.BUF
	CALL	ITOA
	CALL	SKIP
	CALL	PUTS
	JR	P.END

P.HEX:	CP	'x'
	JR	NZ,P.END
	LD	C,L
	LD	B,H
	CALL	HEX
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
P.BUF:	DS	6
P.PAD:	DB	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	PERROR

PERROR:	LD	DE,(ERRNO)
	;CONTINUE IN STRERROR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INPUT:	E = ERROR NUMBER

	CSEG
	PUBLIC	STRERROR
	EXTRN	ERRSTR

STRERROR:
	LD	A,E
	LD	DE,ERRSTR
	DEC	A
	CALL	ARYDE			;TAKE THE POINTER TO THE STRING
	JP	PUTS			;PRINT IT

	DSEG
	PUBLIC	ERRNO
ERRNO:	DB	0

