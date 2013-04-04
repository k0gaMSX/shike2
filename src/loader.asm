
BUFSIZ	EQU	100H
REPCNT	EQU	4000H/BUFSIZ
PAGE	EQU	8000H

	CSEG
	PUBLIC	MAIN

MAIN:	DI
	IN	A,(0FEH)
	LD	(MAPPER),A

	LD	B,REPCNT
	LD	HL,8000H

LOOP:	PUSH	BC
	PUSH	HL
	LD	DE,BUFFER
	LD	BC,BUFSIZ
	LDIR
	LD	A,(PAGE)
	ADD	A,6
	OUT	(0FEH),A
	POP	DE
	LD	HL,BUFFER
	LD	BC,BUFSIZ
	LDIR
	EX	DE,HL
	LD	A,(MAPPER)
	OUT	(0FEH),A
	POP	BC
	DJNZ	LOOP
	EI
	RET

MAPPER:	DB	0
BUFFER:	DB	0
