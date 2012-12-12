	INCLUDE	DOS.INC

	PUBLIC	PRINTE,PRINTL,PRINT

	CSEG
PRINT:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	C,STROUT
	CALL	BDOS
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
PRINTL:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	C,STROUT
	CALL	BDOS
	LD	DE,NEWLINE
	LD	C,STROUT
	CALL	BDOS
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
PRINTE:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	CALL	HEX2ASC

	PUSH	BC
	LD	E,B
	LD	C,CONOUT
	CALL	BDOS

	POP	BC
	LD	E,C
	LD	C,CONOUT
	CALL	BDOS

	LD	DE,NEWLINE
	LD	C,STROUT
	CALL	BDOS
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
HEX2ASC:
	LD	A,E
	AND	0FH
	CP	10
	JR	NC,.HEX1
	ADD	A,'0'
	LD	C,A
	JR	.2ND

.HEX1:	ADD	A,'A'-10
	LD	C,A

.2ND:	LD	A,E
	RRCA
	RRCA
	RRCA
	RRCA
	AND	0FH
	CP	10
	JR	NC,.HEX2
	ADD	A,'0'
	LD	B,A
	RET

.HEX2:	ADD	A,'A'-10
	LD	B,A
	RET

NEWLINE:	DB	0AH,0DH,'$'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSEG
NL:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	DE,NEWLINE
	LD	C,STROUT
	CALL	BDOS
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET

