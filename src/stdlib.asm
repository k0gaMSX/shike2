
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
	LD	C,0
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
	LDIR
	RET

