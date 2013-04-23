
	INCLUDE	BIOS.INC
	INCLUDE	DATA.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	CPVPAGE,SETPAGE,NEWFRAME,KBHIT,MOB,PUTMOB,EDITOR,MOBINIT

	INCLUDE	EVENT.INC

GAME:	CALL	MOBINIT
	CALL	EDITOR

	LD	E,0
	LD	C,1
	CALL	CPVPAGE

	XOR	A
	LD	(DPPAGE),A
	INC	A
	LD	(ACPAGE),A
	CALL	SETPAGE

	LD	HL,0
	LD	(X1),HL
	LD	(X2),HL

	LD	IX,MOB1
	CALL	MOB
	LD	IX,MOB2
	CALL	MOB

G.LOOP:	CALL	NEWFRAME
	CALL	KBHIT
	CP	KB_ESC
	JR	NZ,G.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	ENGINE

ENGINE:	LD	IX,MOB1
	LD	A,(X1)
	LD	L,A
	LD	H,0
	DEC	A
	LD	(X1),A
	LD	DE,10
	LD	B,0
	CALL	PUTMOB

	LD	IX,MOB2
	LD	A,(X2)
	LD	L,A
	LD	H,0
	INC	A
	LD	(X2),A
	LD	DE,0
	LD	B,0
	CALL	PUTMOB
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DSEG
MOB1:	DS	MOB.SIZ
MOB2:	DS	MOB.SIZ
X1:	DW	0
X2:	DW	0

