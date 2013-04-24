
	INCLUDE	BIOS.INC
	INCLUDE	DATA.INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CSEG
	PUBLIC	GAME
	EXTRN	MOBINIT,MOVINIT,EDITOR
	EXTRN	SETPAGE,NEWFRAME,KBHIT,MOVABLE,PUTMOB
	EXTRN	CLRVPAGE,CPVPAGE

	INCLUDE	EVENT.INC

GAME:	CALL	MOBINIT
	CALL	MOVINIT
	CALL	EDITOR

	EXTRN	EDLEVEL,EDROOM,MAP

	LD	E,0
	CALL	CLRVPAGE

	LD	DE,(EDLEVEL)
	LD	BC,(EDROOM)
	CALL	MAP

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

	LD	IX,MOV1
	CALL	MOVABLE
	LD	IX,MOV2
	CALL	MOVABLE


G.LOOP:	CALL	NEWFRAME
	CALL	KBHIT
	CP	KB_ESC
	JR	NZ,G.LOOP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PUBLIC	ENGINE

ENGINE:	LD	IX,MOV1
	LD	A,(X1)
	LD	L,A
	LD	H,0
	DEC	A
	LD	(X1),A
	LD	DE,10
	LD	B,0
	CALL	PUTMOB

	LD	IX,MOV2
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
MOV1:	DS	MOV.SIZ
MOV2:	DS	MOV.SIZ
X1:	DW	0
X2:	DW	0

